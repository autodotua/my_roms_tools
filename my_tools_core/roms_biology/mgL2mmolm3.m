function molPerM3 = mgL2mmolm3(mgL,molarMass)
    %从mg/L转到millimole/m^3
    if ischar(molarMass) || isstring(molarMass)
        molarMass=getMolarMass(molarMass);
    end
    molPerM3=mgL/molarMass*1000;
end

function molarMass = getMolarMass(element)
    element=char(element);
    switch element
        case 'H'
            molarMass = 1.008;
        case 'He'
            molarMass = 4.0026;
        case 'Li'
            molarMass = 6.94;
        case 'Be'
            molarMass = 9.0122;
        case 'B'
            molarMass = 10.81;
        case 'C'
            molarMass = 12.01;
        case 'N'
            molarMass = 14.01;
        case 'O'
            molarMass = 16.00;
        case 'F'
            molarMass = 19.00;
        case 'Ne'
            molarMass = 20.18;
        case 'Na'
            molarMass = 22.99;
        case 'Mg'
            molarMass = 24.31;
        case 'Al'
            molarMass = 26.98;
        case 'Si'
            molarMass = 28.09;
        case 'P'
            molarMass = 30.97;
        case 'S'
            molarMass = 32.07;
        case 'Cl'
            molarMass = 35.45;
        case 'K'
            molarMass = 39.10;
        case 'Ar'
            molarMass = 39.95;
        case 'Ca'
            molarMass = 40.08;
        case 'Sc'
            molarMass = 44.96;
        case 'Ti'
            molarMass = 47.87;
        case 'V'
            molarMass = 50.94;
        case 'Cr'
            molarMass = 52.00;
        case 'Mn'
            molarMass = 54.94;
        case 'Fe'
            molarMass = 55.85;
        case 'Ni'
            molarMass = 58.69;
        case 'Cu'
            molarMass = 63.55;
        case 'Zn'
            molarMass = 65.38;
        otherwise
            error('未知元素');
    end
end
