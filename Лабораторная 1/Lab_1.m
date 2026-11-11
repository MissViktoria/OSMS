% Вариант 24
% y(t) = 5*sin(2*pi*f*t + pi/7), f = 10 Гц

sample = 10000;              % плотность для непрерывного графика
T = 1;                       % длительность, с
f = 10;                      % частота сигнала, Гц
A = 5;                       % амплитуда
phi = pi/7;                  % фаза

% Мяу 1: непрерывный сигнал
t = 0:1/sample:T;
yfunc = @(t) A * sin(2 * pi * f * t + phi);
y = yfunc(t);
figure;
plot(t, y, 'b');
grid on;
title('Мяу 1. Непрерывный сигнал');

% Мяу 2: макс частота
Fmax = f;
disp(['Мяу 2. Fmax = ', num2str(Fmax), ' Гц']);

% Мяу 3: мин частота по Котельникову
Fs_min = 2 * Fmax;
disp(['Мяу 3. Fs_min = ', num2str(Fs_min), ' Гц']);

% Мяу 4: оцифровка с Fs_min
Fs = Fs_min;
N = Fs * T;                  % число отсчетов
td = (0:N-1) / Fs;
yd = yfunc(td);
figure;
stem(td, yd, 'r');
grid on;
title(['Мяу 4. Отсчеты (Fs = ', num2str(Fs), ' Гц)']);

% Мяу 5: своё ДПФ
spectr = zeros(1, N);
for x = 0:N-1
    s = 0;
    for n = 0:N-1
        s = s + yd(n+1) * exp(-1j * 2 * pi * x * n / N);
    end
    spectr(x+1) = s;
end
Amp = abs(spectr);
fax = (0:N-1) * Fs / N;
figure;
stem(fax, Amp, 'b');
grid on;
title('Мяу 5. Амплитудный спектр (Fs = 20 Гц)');

mem = N * 8;
disp(['Мяу 5. Память (double): ', num2str(mem), ' байт']);

% Мяу 6: восстановление
figure;
plot(t, y, 'b'); hold on;
plot(td, yd, 'ro-');
grid on;
title('Мяу 6. Восстановление (Fs = 20 Гц)');
legend('Оригинал', 'Восстановленный');

% Мяу 7: Fs x4
Fs4 = Fs * 4;
N4 = Fs4 * T;
td4 = (0:N4-1) / Fs4;
yd4 = yfunc(td4);
spectr4 = zeros(1, N4);
for x = 0:N4-1
    s = 0;
    for n = 0:N4-1
        s = s + yd4(n+1) * exp(-1j * 2 * pi * x * n / N4);
    end
    spectr4(x+1) = s;
end
Amp4 = abs(spectr4);
fax4 = (0:N4-1) * Fs4 / N4;
figure;
stem(fax4, Amp4, 'b');
grid on;
title('Мяу 7. Спектр (Fs = 80 Гц)');

figure;
plot(t, y, 'b'); hold on;
plot(td4, yd4, 'go-');
grid on;
title('Мяу 7. Восстановление (Fs = 80 Гц)');
legend('Оригинал', 'Восстановленный');