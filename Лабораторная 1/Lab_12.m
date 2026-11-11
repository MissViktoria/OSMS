% Мяу 9: загрузка аудиофайла
[y_full, Fs] = audioread('Voice.wav');   
if size(y_full, 2) > 1
    y_full = y_full(:, 1);
end

disp(['Мяу 9. Файл загружен. Отсчетов: ', num2str(length(y_full))]);
disp(['Мяу 9. Fs из файла: ', num2str(Fs), ' Гц']);

% Мяу 10: определение Fs через length/dur
dur = length(y_full) / Fs;
disp(['Мяу 10. Длительность записи: ', num2str(dur), ' с']);

Fs_check = length(y_full) / dur;
disp(['Мяу 10. Fs вычисл = ', num2str(Fs_check), ...
      ' | Fs из audioread = ', num2str(Fs)]);

% Обрезаем тишину в начале
threshold_silence = 0.01 * max(abs(y_full));   % порог 1% от пика
first_sound = find(abs(y_full) > threshold_silence, 1);   % первый громкий отсчёт
y_full = y_full(first_sound:end);              % обрезаем тишину
disp(['Тишина обрезана, начинаем с отсчёта ', num2str(first_sound)]);

% Для ДПФ берём только кусок сигнала
N_use = 8192;
y = y_full(1:min(N_use, length(y_full)));
disp(['Для ДПФ используем первые ', num2str(length(y)), ' отсчетов']);

% Мяу 12.а: своё ДПФ для оригинального голоса
N = length(y);
n_idx = 0:N-1;
x_idx = (0:N-1)';
W = exp(-1j * 2 * pi * x_idx * n_idx / N);
spectr = (W * y).';
Amp = abs(spectr);
fax = (0:N-1) * Fs / N;
half = floor(N/2) + 1;

figure;
plot(fax(1:half), Amp(1:half), 'b');
grid on;
title('Мяу 12. Спектр оригинального голоса');
xlabel('Частота, Гц'); ylabel('|F(x)|');
xlim([0 Fs/2]);

% Ширина спектра оригинала по уровню -3 дБ
[max_val, max_idx] = max(Amp(1:half));
threshold = max_val / sqrt(2);

i_left = max_idx;
while i_left > 1 && Amp(i_left) > threshold
    i_left = i_left - 1;
end
i_right = max_idx;
while i_right < half && Amp(i_right) > threshold
    i_right = i_right + 1;
end

width_3dB = fax(i_right) - fax(i_left);
disp(['Мяу 12. Ширина спектра оригинала (-3 дБ): ', ...
      num2str(width_3dB), ' Гц (от ', num2str(fax(i_left)), ...
      ' до ', num2str(fax(i_right)), ' Гц)']);

% Мяу 11: прореживание ПОЛНОГО сигнала в 10 раз
y1 = downsample(y_full, 10);
Fs1 = Fs / 10;
disp(['Мяу 11. Прореженный сигнал: ', num2str(length(y1)), ' отсчетов']);
disp(['Мяу 11. Fs после прореживания: ', num2str(Fs1), ' Гц']);

% сохранение на рабочий стол
home = getenv('USERPROFILE');
if exist(fullfile(home, 'Desktop'), 'dir')
    desktop = fullfile(home, 'Desktop');
else
    desktop = fullfile(home, 'Рабочий стол');
end
out_path = fullfile(desktop, 'voice_downsampled.wav');
audiowrite(out_path, y1, Fs1);
disp(['Мяу 11. Сохранён: ', out_path]);

% проигрывание
try
    player = audioplayer(y1, Fs1);
    play(player);
    disp('Мяу 11. Проигрывается прореженный сигнал...');
catch
    disp('Мяу 11. Воспроизведение в Matlab недоступно.');
end

figure;
plot(y1, 'b');
grid on;
title('Мяу 11. Прореженный сигнал (полный)');

% Мяу 12.б: своё ДПФ для прореженного сигнала (берём кусок)
N1_use = 8192;
y1_dft = y1(1:min(N1_use, length(y1)));
N1 = length(y1_dft);
n1 = 0:N1-1;
x1 = (0:N1-1)';
W1 = exp(-1j * 2 * pi * x1 * n1 / N1);
spectr1 = (W1 * y1_dft).';
Amp1 = abs(spectr1);
fax1 = (0:N1-1) * Fs1 / N1;
half1 = floor(N1/2) + 1;

figure;
plot(fax1(1:half1), Amp1(1:half1), 'r');
grid on;
title('Мяу 12. Спектр прореженного голоса (Fs/10)');
xlabel('Частота, Гц'); ylabel('|F(x)|');
xlim([0 Fs1/2]);

% Ширина спектра прореженного по -3 дБ
[max_val1, max_idx1] = max(Amp1(1:half1));
threshold1 = max_val1 / sqrt(2);

i_left1 = max_idx1;
while i_left1 > 1 && Amp1(i_left1) > threshold1
    i_left1 = i_left1 - 1;
end
i_right1 = max_idx1;
while i_right1 < half1 && Amp1(i_right1) > threshold1
    i_right1 = i_right1 + 1;
end

width_3dB_1 = fax1(i_right1) - fax1(i_left1);
disp(['Мяу 12. Ширина спектра прореженного (-3 дБ): ', ...
      num2str(width_3dB_1), ' Гц']);

% Мяу 13: квантование по разрядности АЦП
bits_list = [3, 4, 5, 6];
t_short = (0:N-1) / Fs;

for b = bits_list
    yq = quantize_signal(y, b);
    err = mean(abs(y - yq));
    disp(['Мяу 13. bits = ', num2str(b), ...
          ' | средняя ошибка квантования = ', num2str(err)]);
end

yq3 = quantize_signal(y, 3);
yq6 = quantize_signal(y, 6);

figure;
subplot(3,1,1);
plot(t_short, y, 'b'); grid on;
title('Оригинал');
subplot(3,1,2);
plot(t_short, yq3, 'r'); grid on;
title('Квантование 3 бита');
subplot(3,1,3);
plot(t_short, yq6, 'g'); grid on;
title('Квантование 6 бит');

% ДПФ квантованного сигнала (3 бита) и сравнение спектров
spectr_q3 = (W * yq3).';
Amp_q3 = abs(spectr_q3);

figure;
plot(fax(1:half), Amp(1:half), 'b'); hold on;
plot(fax(1:half), Amp_q3(1:half), 'r');
grid on;
title('Мяу 13. Спектр: оригинал vs квантование 3 бита');
xlabel('Частота, Гц'); ylabel('|F(x)|');
legend('Оригинал', '3 бита');
xlim([0 Fs/2]);

% ДПФ квантованного сигнала (6 бит) и сравнение спектров
spectr_q6 = (W * yq6).';
Amp_q6 = abs(spectr_q6);

figure;
plot(fax(1:half), Amp(1:half), 'b'); hold on;
plot(fax(1:half), Amp_q6(1:half), 'g');
grid on;
title('Мяу 13. Спектр: оригинал vs квантование 6 бит');
xlabel('Частота, Гц'); ylabel('|F(x)|');
legend('Оригинал', '6 бит');
xlim([0 Fs/2]);

% Функция квантования
function yq = quantize_signal(y, bits)
    % Квантование сигнала по уровню для АЦП заданной разрядности
    levels = 2^bits;
    ymin = min(y);
    ymax = max(y);
    y_norm = (y - ymin) / (ymax - ymin);
    y_q = round(y_norm * (levels - 1));
    yq = y_q / (levels - 1) * (ymax - ymin) + ymin;
end