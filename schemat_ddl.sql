- ===================================
-- System Zarządzania Uczelnią
-- Kreacja tabeli i relacji
-- System ocen: 2 (ndst), 3 (dst), 4 (db), 5 (bdb)
-- ===================================

-- Tabela Kierunki
CREATE TABLE Kierunki (
    ID_kierunku NUMBER PRIMARY KEY,
    Nazwa_kierunku VARCHAR2(100) NOT NULL,
    Wydzial VARCHAR2(100) NOT NULL,
    Stopien VARCHAR2(20) CHECK (Stopien IN ('licencjackie', 'magisterskie', 'inzynierskie')) NOT NULL,
    Limit_miejsc NUMBER DEFAULT 100 CHECK (Limit_miejsc > 0)
);

-- Tabela Studenci 
CREATE TABLE Studenci (
    ID_studenta NUMBER PRIMARY KEY,
    Imie VARCHAR2(50) NOT NULL,
    Nazwisko VARCHAR2(50) NOT NULL,
    Nr_albumu VARCHAR2(20) UNIQUE NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    ID_kierunku NUMBER NOT NULL,
    Rok_studiow NUMBER CHECK (Rok_studiow BETWEEN 1 AND 5) NOT NULL,
    Data_rozpoczecia DATE DEFAULT SYSDATE,
    Status VARCHAR2(20) DEFAULT 'aktywny' CHECK (Status IN ('aktywny', 'urlop', 'skreslony', 'absolwent')),
    CONSTRAINT fk_studenci_kierunki FOREIGN KEY (ID_kierunku) REFERENCES Kierunki(ID_kierunku)
);

-- Tabela Wykladowcy
CREATE TABLE Wykladowcy (
    ID_wykladowcy NUMBER PRIMARY KEY,
    Imie VARCHAR2(50) NOT NULL,
    Nazwisko VARCHAR2(50) NOT NULL,
    Tytul VARCHAR2(50) CHECK (Tytul IN ('mgr', 'dr', 'dr hab.', 'prof.')) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Katedra VARCHAR2(100) NOT NULL
);

-- Tabela Przedmioty 
CREATE TABLE Przedmioty (
    ID_przedmiotu NUMBER PRIMARY KEY,
    Kod_przedmiotu VARCHAR2(20) UNIQUE NOT NULL,
    Nazwa_przedmiotu VARCHAR2(150) NOT NULL,
    Punkty_ECTS NUMBER CHECK (Punkty_ECTS > 0) NOT NULL,
    ID_wykladowcy NUMBER NOT NULL,
    Typ_zajec VARCHAR2(30) CHECK (Typ_zajec IN ('wyklad', 'cwiczenia', 'laboratorium', 'seminarium')) NOT NULL,
    Limit_studentow NUMBER DEFAULT 30 CHECK (Limit_studentow > 0),
    Semestr VARCHAR2(10) CHECK (Semestr IN ('zimowy', 'letni')) NOT NULL,
    CONSTRAINT fk_przedmioty_wykladowcy FOREIGN KEY (ID_wykladowcy) REFERENCES Wykladowcy(ID_wykladowcy)
);

-- Tabela Semestry 
CREATE TABLE Semestry (
    ID_semestru NUMBER PRIMARY KEY,
    Rok_akademicki VARCHAR2(9) NOT NULL, -- format: 2024/2025
    Semestr VARCHAR2(10) CHECK (Semestr IN ('zimowy', 'letni')) NOT NULL,
    Data_rozpoczecia DATE NOT NULL,
    Data_zakonczenia DATE NOT NULL,
    CONSTRAINT uk_semestr UNIQUE (Rok_akademicki, Semestr)
);

-- Tabela pośrednia Student_Semestr
CREATE TABLE Student_Semestr (
    ID_student_semestr NUMBER PRIMARY KEY,
    ID_studenta NUMBER NOT NULL,
    ID_semestru NUMBER NOT NULL,
    Status VARCHAR2(20) DEFAULT 'w trakcie' CHECK (Status IN ('w trakcie', 'zaliczony', 'niezaliczony')),
    Data_rozpoczecia DATE NOT NULL,
    Data_zakonczenia DATE NOT NULL,
    CONSTRAINT fk_ss_studenci FOREIGN KEY (ID_studenta) REFERENCES Studenci(ID_studenta) ON DELETE CASCADE,
    CONSTRAINT fk_ss_semestry FOREIGN KEY (ID_semestru) REFERENCES Semestry(ID_semestru) ON DELETE CASCADE,
    CONSTRAINT uk_student_semestr UNIQUE (ID_studenta, ID_semestru)
);

-- Tabela Zapisy
CREATE TABLE Zapisy (
    ID_student_semestr NUMBER NOT NULL,
    ID_zapisu NUMBER NOT NULL,
    ID_przedmiotu NUMBER NOT NULL,
    Data_zapisu DATE DEFAULT SYSDATE,
    Ocena_koncowa NUMBER(1) CHECK (Ocena_koncowa IN (2, 3, 4, 5)) ,
    Status_zapisu VARCHAR2(20) DEFAULT 'zapisany' CHECK (Status_zapisu IN ('zapisany', 'zaliczony', 'niezaliczony', 'rezygnacja')),
    Punkty_ECTS_uzyskane NUMBER DEFAULT 0,
    PRIMARY KEY (ID_student_semestr, ID_zapisu),
    CONSTRAINT fk_zapisy_ss FOREIGN KEY (ID_student_semestr) 
        REFERENCES Student_Semestr(ID_student_semestr) ON DELETE CASCADE,
    CONSTRAINT fk_zapisy_przedmioty FOREIGN KEY (ID_przedmiotu) 
        REFERENCES Przedmioty(ID_przedmiotu)
);

-- Tabela Oceny_czastkowe
CREATE TABLE Oceny_czastkowe (
    ID_oceny NUMBER PRIMARY KEY,
    ID_student_semestr NUMBER NOT NULL,
    ID_zapisu NUMBER NOT NULL,
    Rodzaj_oceny VARCHAR2(50) NOT NULL, -- np. 'kolokwium 1', 'projekt', 'egzamin'
    Ocena NUMBER(1) CHECK (Ocena IN (2, 3, 4, 5)) NOT NULL,
    Data_wystawienia DATE DEFAULT SYSDATE,
    Waga NUMBER(3,2) DEFAULT 1 CHECK (Waga BETWEEN 0 AND 1),
    CONSTRAINT fk_oceny_zapisy FOREIGN KEY (ID_student_semestr, ID_zapisu) 
        REFERENCES Zapisy(ID_student_semestr, ID_zapisu) ON DELETE CASCADE
);