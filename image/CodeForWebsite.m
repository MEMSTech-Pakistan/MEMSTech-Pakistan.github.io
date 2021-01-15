clc
density=2500;              %Silicon density
Ey= 169e9;                 %Young's Modulus of Silicon
h = 25e-6;                 %Thickness of structure
w_beam = 10e-6;            %width of beam
eo = 8.85e-12;             %permitivity 
e = 1;
n = 110;                   %total number of finger pairs 
width = h;                 %widht of fingers
d1 = 9e-6;                 %Large Gap Between Fingers
d2 = 3e-6;                 %Large Gap Between Fingers
lo = 150e-6;               %Initial Overlap
%a = 50e-6;                 %Displacement
Vmax = 50;                 %Maximum Voltage
Vmin = 2;                  %Initial Voltage
mu=4*pi*1e-7;              %permeability
p=300;                     %atmospheric pressure
zo=0.2e-6;                 %elevation infinity in SOI MUMPS
syms om;

%Calculation for Masses
x_length_m1 = 3600e-6;
y_length_m1 = 3000e-6;
width_m1 = 200e-6;

x_length_m2 = 3000e-6;
y_length_m2 = 2400e-6;
width_m2 = 200e-6;

x_length_mf = 2600e-6;
y_length_mf = 1800e-6;
width_mf = 100e-6;

x_length_m3a = 2000e-6;
y_length_m3a = 1400e-6;
width_m3a = 200e-6;

x_length_m3b = 1800e-6;
y_length_m3b = 800e-6;
width_m3b = 800e-6;

%Area Calculation for Comb-drive in Mass-3b
Afinger = 8e-6*200e-6;
Apad = 100e-6*1540e-6;
% Acombs = Apad+(Afinger*110)
Acombs=110*Afinger;

area_m1 = 2*(x_length_m1*width_m1)+2*(y_length_m1*width_m1);
area_m2 = 2*(x_length_m2*width_m2)+2*(y_length_m2*width_m2);
area_mf = 2*(x_length_mf*width_mf)+2*(y_length_mf*width_mf);
area_m3a = 2*(x_length_m3a*width_m3a)+2*(y_length_m3a*width_m3a);
area_m3b = ((x_length_m3b*width_m3b)-(600e-6*1600e-6))+Acombs;
%Masses
m1 = density*(h*area_m1)
m2 = density*(h*area_m2)
mf = density*(h*area_mf)
m3a = density*(h*area_m3a)
m3b = density*(h*area_m3b)
mass_of_combs = density*(h*Acombs)
m3=mf+m3a+m3b
total_volume = (m1+m2+m3)/density
%Spring Constant Calculation
w_k1 = 10e-6;    %Width of beam for spring K1
L_k1 = 600e-6;   %Length of beam for K1

w_k12 = 16e-6;
L_k12 = 600e-6;

w_k2 = 10e-6;
L_k2 = 600e-6;

w_k23 = 20e-6;
L_k23 = 600e-6;

w_k3 = 10e-6;
L_k3 = 600e-6;

w_k4 = 10e-6;
L_k4 = 500e-6;

w_k45 = 10e-6;
L_k45 = 250e-6;

w_k5 = 10e-6;
L_k5 = 250e-6;

%individual beam deflections
k1 = (4/2)*((Ey*h*w_k1^3)/(L_k1^3))

k12 = (4/4)*((Ey*h*w_k12^3)/(L_k12^3))

k2 = (4/2)*((Ey*h*w_k2^3)/(L_k2^3))

k23 = (4/4)*((Ey*h*w_k23^3)/(L_k23^3))

k3 = (4/2)*((Ey*h*w_k3^3)/(L_k3^3))

k4 = (4/5)*((Ey*h*w_k4^3)/(L_k4^3))

k45 = (4/5)*((Ey*h*w_k45^3)/(L_k45^3))

k5 = (2/2)*((Ey*h*w_k5^3)/(L_k5^3))
%Natural Frequency Calculation
M = [m1 0 0;
     0 m2 0;
     0 0 m3];

K = [(k1+k2) -k12 0;
     -k12 (k2+k12+k23) -k23;
      0 -k23 (k3+k23)];
% %Finding Eigen Values
Y = abs(eig(K\M));
% %Natural Frequency in kHz
f1 = (sqrt(Y(3)))/(2*pi)/1000;
f2 = (sqrt(Y(2)))/(2*pi)/1000;
f3 = (sqrt(Y(1)))/(2*pi)/1000;
%Un-damped Natural Freq
f1n = ((1/(2*pi))*(sqrt(k1/m1)))/1000;
f2n = ((1/(2*pi))*(sqrt(k12/m2)))/1000;
f3n = ((1/(2*pi))*(sqrt(k23/m3)))/1000;
%Dampers
c1=(mu*p*(240*40e-6*h))/(3e-6);
c2=0;
c3=(mu*p*(110*200e-6*h))/(3e-6);
b1=0;
b2=0;
b3=c3/(2*sqrt(m3*k23));
%Applied Force
F = 1*10^(-6);
%Frequency
w= 0:1:120000;
frq= w/(2*pi);

for i=1:length(w)

    T=[(-(w(i)^2)*m1+k1+k12)+1j*w(i)*c1 -k12 0 -w(i)*c1 0 0;
        -k12 (-(w(i)^2)*m2+k2+k12+k23)+1j*w(i)*c2 -k23 0 -w(i)*c2 0;
        0 -k23 (-(w(i)^2)*m3+k3+k23)+1j*w(i)*c3 0 0 -w(i)*c3;
        w(i)*c1 0 0 (-(w(i)^2)*m1+k1+k12) -k12 0;
        0 w(i)*c2 0 -k12 (-(w(i)^2)*m2+k2+k12+k23) -k23;
        0 0 w(i)*c3 0 -k23 (-(w(i)^2)*m3+k3+k23)];

   
    A=abs((inv(T)))*[F;0;0;0;0;0];
    
    X1(i)=sqrt(A(1)^2+A(4)^2);
    X2(i)=sqrt(A(2)^2+A(5)^2);
    X3(i)=sqrt(A(3)^2+A(6)^2);
    phi_1(i)=atan(-A(4)/A(1));
    phi_2(i)=atan(-A(5)/A(2));
    phi_3(i)=atan(-A(6)/A(3));
    
end
hold on;grid on;grid minor;
plot(frq,X1,'b')
plot(frq,X2,'k')
plot(frq,X3,'r')
legend('X1','X2','X3')
xlabel('Frequency (Hz)');
ylabel('Displacement of Masses (m)');
title('Frequency Analysis')

