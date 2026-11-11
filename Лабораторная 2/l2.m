P_TxBS = 46; % дБм
P_TxUE = 24; % дБм
N_sectors = 3;
G_AntBS = 21; % дБи
PenetrationM = 15; % дБ
IM = 1; % дБ
f_MHz = 1800; % МГц
f_GHz = f_MHz/1000;
BW_UL = 10e6; % Гц
BW_DL = 20e6; % Гц
NF_BS = 2.4; % дБ
NF_UE = 6; % дБ
SINR_DL = 2; % дБ
SINR_UL = 4; % дБ
MIMO_ant = 2;

FeederLoss = 2 + 0.4 + 0.5; % дБ
MIMOGain = 10*log10(MIMO_ant); % дБ

hBS = 30; % м
hms = 1.5; % м
clutter = 'U';

S_macro = 100; % км^2
S_micro = 4; % км^2

c = 3e8;

% Чувствительность приёмников
ThermalNoise_UL = -174 + 10*log10(BW_UL);
ThermalNoise_DL = -174 + 10*log10(BW_DL);

RxSens_BS = NF_BS + ThermalNoise_UL + SINR_UL;
RxSens_UE = NF_UE + ThermalNoise_DL + SINR_DL;

% Бюджеты каналов (MAPL)
MAPL_DL = P_TxBS - FeederLoss + G_AntBS + MIMOGain ...
 - IM - PenetrationM - RxSens_UE;

MAPL_UL = P_TxUE - FeederLoss + G_AntBS + MIMOGain ...
 - IM - PenetrationM - RxSens_BS;

% Модели распространения
d_m = logspace(0, 5, 2000);
d_km = d_m / 1000;

PL_FSPM = 20*log10(4*pi*d_m*(f_MHz*1e6)/c);
PL_UMi = 26*log10(f_GHz) + 22.7 + 36.7*log10(d_m);

if f_MHz <= 1500
 A = 69.55; B = 26.16;
else
 A = 46.33; B = 33.90;
end

a_hms = 3.2*(log10(11.75*hms))^2 - 4.97;

Lclutter = 0;

s = (47.88 + 13.9*log10(f_MHz) - 13.9*log10(hBS)) / log10(50);

PL_Hata = A + B*log10(f_MHz) - 13.82*log10(hBS) - a_hms + s*log10(d_km) + Lclutter;

% Радиусы и число БС
d_UL_macro = interp1(PL_Hata, d_km, MAPL_UL, 'linear', NaN);
d_DL_macro = interp1(PL_Hata, d_km, MAPL_DL, 'linear', NaN);
R_macro = min(d_UL_macro, d_DL_macro);
S_BS_macro = 1.95 * R_macro^2;
N_BS_macro = ceil(S_macro / S_BS_macro);

d_UL_micro = interp1(PL_UMi, d_km, MAPL_UL, 'linear', NaN);
d_DL_micro = interp1(PL_UMi, d_km, MAPL_DL, 'linear', NaN);
R_micro = min(d_UL_micro, d_DL_micro);
S_BS_micro = 1.95 * R_micro^2;
N_BS_micro = ceil(S_micro / S_BS_micro);

% Вывод
fprintf('Исходные данные\n');
fprintf('Частота %d МГц\n', f_MHz);
fprintf('Полоса UL %d МГц\n', BW_UL/1e6);
fprintf('Полоса DL %d МГц\n', BW_DL/1e6);
fprintf('Мощность BS %d дБм\n', P_TxBS);
fprintf('Мощность UE %d дБм\n', P_TxUE);
fprintf('Усиление антенны BS %d дБи\n', G_AntBS);
fprintf('Потери в фидерном тракте %.2f дБ\n', FeederLoss);
fprintf('Выигрыш MIMO %.2f дБ\n', MIMOGain);
fprintf('Запас на проникновение %d дБ\n', PenetrationM);
fprintf('Запас на интерференцию %d дБ\n\n', IM);

fprintf('Чувствительность приёмников\n');
fprintf('Тепловой шум UL %.2f дБм\n', ThermalNoise_UL);
fprintf('Тепловой шум DL %.2f дБм\n', ThermalNoise_DL);
fprintf('Чувствительность BS %.2f дБм\n', RxSens_BS);
fprintf('Чувствительность UE %.2f дБм\n\n', RxSens_UE);

fprintf('Бюджеты каналов\n');
fprintf('MAPL_UL %.2f дБ\n', MAPL_UL);
fprintf('MAPL_DL %.2f дБ\n\n', MAPL_DL);

fprintf('Параметры COST 231 Hata\n');
fprintf('A %.2f\n', A);
fprintf('B %.2f\n', B);
fprintf('a(hms) %.4f дБ\n', a_hms);
fprintf('Lclutter %.4f дБ\n', Lclutter);
fprintf('s %.4f\n\n', s);

fprintf('Макросоты COST 231 Hata\n');
fprintf('Радиус UL %.4f км\n', d_UL_macro);
fprintf('Радиус DL %.4f км\n', d_DL_macro);
fprintf('Радиус соты %.4f км\n', R_macro);
fprintf('Площадь одной БС %.4f км^2\n', S_BS_macro);
fprintf('Число БС на %d км^2 %d\n\n', S_macro, N_BS_macro);

fprintf('МИКРО и ФЕМТО UMiNLOS\n');
fprintf('Радиус UL %.5f км\n', d_UL_micro);
fprintf('Радиус DL %.5f км\n', d_DL_micro);
fprintf('Радиус соты %.5f км\n', R_micro);
fprintf('Площадь одной БС %.6f км^2\n', S_BS_micro);
fprintf('Число БС на %d км^2 %d\n\n', S_micro, N_BS_micro);

fprintf('Сводная таблица\n');
fprintf('Параметр Макросоты Микро\n');
fprintf('d_UL км %.4f %.5f\n', d_UL_macro, d_UL_micro);
fprintf('d_DL км %.4f %.5f\n', d_DL_macro, d_DL_micro);
fprintf('R км %.4f %.5f\n', R_macro, R_micro);
fprintf('S_BS км^2 %.4f %.5f\n', S_BS_macro, S_BS_micro);
fprintf('N_BS %d %d\n\n', N_BS_macro, N_BS_micro);

fprintf('Вывод\n');
fprintf('Покрытие ограничено восходящим каналом, так как MAPL_UL меньше MAPL_DL\n');
fprintf('Радиус макросоты %.2f км\n', R_macro);
fprintf('Радиус микро и фемтосоты %.3f км\n', R_micro);

% График
figure('Name','Потери от расстояния','Color','w');
semilogx(d_m, PL_FSPM, 'b--', 'LineWidth', 1.6); hold on;
semilogx(d_m, PL_UMi, 'r-', 'LineWidth', 1.6);
semilogx(d_m, PL_Hata, 'k-.', 'LineWidth', 1.6);
yline(MAPL_UL, 'm--', 'MAPL UL', 'LineWidth', 1.3);
yline(MAPL_DL, 'g--', 'MAPL DL', 'LineWidth', 1.3);
grid on; box on;
xlabel('Расстояние d, м');
ylabel('Потери сигнала PL, дБ');
title('Потери радиосигнала от расстояния f = 1.8 ГГц');
legend('FSPM','UMiNLOS','COST 231 Hata','MAPL UL','MAPL DL','Location','northwest');
ylim([0 170]);