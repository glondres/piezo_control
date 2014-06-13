% function analysis(T,t,g)

%%
[envelope, envelop_loc] = findpeaks(abs(gf));

count = 0;
hull = [];
hull_loc = [];
current_max = envelope(end);
for i = length(envelop_loc):-1:1
    if current_max < envelope(i)
        current_max = envelope(i);
        hull = [hull current_max];
        hull_loc = [hull_loc envelop_loc(i)];
    end
end

hull = hull(end:-1:1)';
hull_loc = hull_loc(end:-1:1)';


plot(t(hull_loc),hull)

%%

model = fit(t(hull_loc), (hull), 'exp1');
k_fit = model.a;
tau_fit = -1/model.b;
% p = polyfit(t_wave(envelop_loc), log(envelope), 1);
% tau_fit = -1/p(1);
% k_fit = exp(p(2));
% plot(t_wave, wave, t_wave(envelop_loc), envelope, 'or', t_wave, k_fit * exp(-t_wave / tau_fit), '-k')

%%
NFFT = 2^nextpow2(length(t)); % Next power of 2 from length of y
% NFFT = 4;
Y = fft(g,NFFT);
f = 1/2/T*linspace(0,1,NFFT/2+1)';

%%

new_Y = Y(1:NFFT/2+1);
Y_abs = abs(new_Y(f>1));
[pvals, pplaces] = findpeaks(Y_abs);
new_f = f(f>1);
[NOT_USED, max_place] = max(pvals);
f_damped = new_f(pplaces(max_place));
w_damped = 2*pi*f_damped;

phase_1 = angle(new_Y(pplaces(max_place)))

%% Find Q-Factor

Y_max_value = max(Y_abs);
[aux,index] = sort(abs(Y_abs - Y_max_value/sqrt(2)));

f_1 = new_f(index(1))
f_2 = new_f(index(2))

Q = f_damped / abs(f_1 - f_2);
damping_from_Q = 1/(2*Q);

%% Plot single-sided amplitude spectrum.

fig = figure;
hax = axes;
hold on
plot(f,abs(new_Y),'k')
title('Single-Sided Amplitude Spectrum of a_z(t)')
line([f_damped f_damped],get(hax,'YLim'));
line([f_1 f_1],get(hax,'YLim'));
line([f_2 f_2],get(hax,'YLim'));
line(get(hax,'XLim'),[Y_max_value/2 Y_max_value/2]);
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
hold off


%% Solve for natural frequency and damping ratio
damping = 1/(tau_fit*w_damped)
% damping   = sqrt(1/(1 + (w_damped*tau_fit)^2));
w_natural = 1/(tau_fit*damping);
f_natural = w_natural / (2*pi);

%% Plot Fitted function

fit_damped = @(t) (k_fit*exp(-t/tau_fit).*sin(w_damped*t-phase_1));

% error = abs(wave - fit_damped(t_wave))./abs(a(max_n)-a(min_n));

to_str = @(var_sym,value,units) [var_sym, ' = ', num2str(value), units];
message = { to_str('\tau',tau_fit,'s'),
            to_str('f',f_damped,'Hz'),
            to_str('\omega',w_damped,'rad/s^2'),
            to_str('\zeta',damping,'')};
        
%% Plot Uncontrolled

hold on
title('Signal with Exponential Envelope');
grid on
% plot(t,fit_damped(t),'k')
plot(t,gf)
plot(t,k_fit*exp(-t/tau_fit),'k')
plot(t,-k_fit*exp(-t/tau_fit),'k')
legend('Meassured Signal','K*e^{-t/\tau}');
text(0.8*t(end),0.5*max(gf),message)
hold off


% end 
%% Fit controlled
% 
% x = [0.927908 0.323765];
% t_fit = [0.1354897 3.843444];
% 
% 	
% tau_fit = diff(t_fit)/log(x(1)/x(2));
% k_fit   = x(1)/exp(-t(1)/tau);
% damping = 1/(w_natural*tau);
%% Plot Controlled
% 
% to_str = @(var_sym,value,units) [var_sym, ' = ', num2str(value), units];
% message = { to_str('\tau',tau_fit,'s'),
%             to_str('f',f_damped,'Hz'),
%             to_str('\omega',w_damped,'rad/s^2'),
%             to_str('\zeta',damping,'')};
% 
% 
% hold on
% title('Signal with Exponential Envelope');
% grid on
% % plot(t,fit_damped(t),'k')
% plot(t,gf)
% plot(t,k_fit*exp(-t/tau_fit),'k')
% plot(t,-k_fit*exp(-t/tau_fit),'k')
% legend('Meassured Signal','K*e^{-t/\tau}');
% text(0.8*t(end),0.5*max(gf),message)
% hold off
