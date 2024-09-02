clc
clear

S1 = readtable('D:\Subham\Al-7075-T651\Experimental data\Flat-DB\UTM\RDB-01.xlsx');
sim = readtable('D:\project\simulation data\data.xlsx');

f = rmmissing(table2array(S1(:,1)))*1000; % Force
d = rmmissing(table2array(S1(:,2))); % Displacement

fsim = rmmissing(table2array(sim(:,2))); 
dsim = rmmissing(table2array(sim(:,1)));

stress_sim = fsim/(3.34*20);
strain_sim = dsim/70;

true_strain_sim = log(1+strain_sim);
true_stress_sim = stress_sim.*(1+strain_sim);

%% Geometry of the specimen

A = 20.1*3.34;
l = 70;

%% Converting force-displacement data to Nominal stress-strain data

nom_strain = d/l; % Nominal strain
nom_stress = f/A; % Nominal stress

%% Finding the stiffness of non-gauge section

E_eff = 3.739e+04;
E_Al = 71000;
E_ex = (E_eff*E_Al)/(E_Al - E_eff);

%% Correction of nominal strain
correct_nom_strain_slope = nom_strain - (nom_stress/E_ex);

intercept = (104.9/70780);

correct_nom_strain = correct_nom_strain_slope + intercept;


%% calculate true stress-strain

true_strain = log(1 + correct_nom_strain);
true_stress = nom_stress.*(1 + nom_strain);

%% Plotting the experimental force-deflection data

figure(1)
hold on
box on
grid minor
plot(d,f/1000,'r','linewidth',2)
xlabel('Displacement (mm)')
ylabel('Force (kN)')
set(gca,'fontsize',14)

%% Plotting the comaprison between the nominal stress-strain data and true data

figure(2)
hold on
box on
grid minor
plot(correct_nom_strain,nom_stress,'b','linewidth',2)
plot(true_strain,true_stress,'m','linewidth',2)
xlabel('Strain(mm/mm)')
ylabel('Stress (MPa)')
set(gca,'fontsize',14)
title('Stress-strain data')
legend('Nominal stress-strain data','True stress-strain')


%% Finding the values of stress-strain for the Power law hardening

n = 0.0850;  % Hardening exponent
sig0 = 497.2; % Initial yield Stress

x = 0:0.001:3;  % Strains for power law
y = ((E_Al*x).^n)*(sig0^(1-n)); % Stresses for power law

plastic_strain = x - (y/E_Al);
yield_stress = y;

plastic_strain = plastic_strain(8:length(plastic_strain));
yield_stress = yield_stress(8:length(yield_stress));
plastic_strain(1) = 0;

%%
hold on
grid minor
box on
plot(plastic_strain,yield_stress,'k','LineWidth',2) % plot of plastic strain VS yield stress
xlabel('Plastic strain')
ylabel('Yield stress (MPa)')
set(gca,'fontsize',14)


%% Comparing experimental and Simulation data

figure(3)
hold on
box on
grid minor
plot(true_strain_sim,true_stress_sim,'g','linewidth',2)
plot(true_strain,true_stress,'m','linewidth',2)
xlabel('Strain(mm/mm)')
ylabel('Stress (MPa)')
set(gca,'fontsize',14)
title('Stress-strain data')
legend('Simulation stress-strain data','Experimental stress-strain data')
