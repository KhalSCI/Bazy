-- ===================================
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

-- ===================================
-- Insert danych na start
-- ===================================

-- Dane kierunków
INSERT INTO Kierunki VALUES (1, 'Informatyka', 'Wydział Matematyki i Informatyki', 'inzynierskie', 150);
INSERT INTO Kierunki VALUES (2, 'Matematyka', 'Wydział Matematyki i Informatyki', 'licencjackie', 80);
INSERT INTO Kierunki VALUES (3, 'Fizyka', 'Wydział Fizyki', 'licencjackie', 60);

-- Dane wykładowców
INSERT INTO Wykladowcy VALUES (1, 'Jan', 'Kowalski', 'dr', 'jan.kowalski@uczelnia.edu.pl', 'Katedra Informatyki');
INSERT INTO Wykladowcy VALUES (2, 'Anna', 'Nowak', 'prof.', 'anna.nowak@uczelnia.edu.pl', 'Katedra Matematyki');
INSERT INTO Wykladowcy VALUES (3, 'Piotr', 'Wiśniewski', 'dr hab.', 'piotr.wisniewski@uczelnia.edu.pl', 'Katedra Fizyki');
INSERT INTO Wykladowcy VALUES (4, 'Maria', 'Zielińska', 'mgr', 'maria.zielinska@uczelnia.edu.pl', 'Katedra Informatyki');

-- Dane studentów
INSERT INTO Studenci VALUES (1, 'Adam', 'Mickiewicz', '123456', 'adam.mickiewicz@student.edu.pl', 1, 2, DATE '2023-10-01', 'aktywny');
INSERT INTO Studenci VALUES (2, 'Maria', 'Skłodowska', '123457', 'maria.sklodowska@student.edu.pl', 2, 1, DATE '2024-10-01', 'aktywny');
INSERT INTO Studenci VALUES (3, 'Mikołaj', 'Kopernik', '123458', 'mikolaj.kopernik@student.edu.pl', 3, 3, DATE '2022-10-01', 'aktywny');
INSERT INTO Studenci VALUES (4, 'Ewa', 'Nowicka', '123459', 'ewa.nowicka@student.edu.pl', 1, 1, DATE '2024-10-01', 'aktywny');
INSERT INTO Studenci VALUES (5, 'Tomasz', 'Lewandowski', '123460', 'tomasz.lewandowski@student.edu.pl', 2, 2, DATE '2023-10-01', 'aktywny');
INSERT INTO Studenci VALUES (6, 'Katarzyna', 'Wójcik', '123461', 'katarzyna.wojcik@student.edu.pl', 3, 1, DATE '2024-10-01', 'aktywny');

-- Dane przedmiotów
INSERT INTO Przedmioty VALUES (1, 'INF101', 'Podstawy programowania', 6, 1, 'wyklad', 100, 'zimowy');
INSERT INTO Przedmioty VALUES (2, 'INF102', 'Bazy danych', 5, 1, 'laboratorium', 30, 'letni');
INSERT INTO Przedmioty VALUES (3, 'MAT101', 'Analiza matematyczna', 7, 2, 'wyklad', 80, 'zimowy');
INSERT INTO Przedmioty VALUES (4, 'INF201', 'Algorytmy i struktury danych', 6, 4, 'cwiczenia', 40, 'zimowy');
INSERT INTO Przedmioty VALUES (5, 'FIZ101', 'Fizyka ogólna', 6, 3, 'wyklad', 60, 'zimowy');

-- Dane semestrów (unikalne okresy)
INSERT INTO Semestry VALUES (1, '2024/2025', 'zimowy', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Semestry VALUES (2, '2024/2025', 'letni', DATE '2025-02-16', DATE '2025-06-30');

-- Przypisanie studentów do semestrów
INSERT INTO Student_Semestr VALUES (1, 1, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Student_Semestr VALUES (2, 2, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Student_Semestr VALUES (3, 3, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Student_Semestr VALUES (4, 4, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Student_Semestr VALUES (5, 5, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');
INSERT INTO Student_Semestr VALUES (6, 6, 1, 'w trakcie', DATE '2024-10-01', DATE '2025-02-15');

-- Zapisy na przedmioty
INSERT INTO Zapisy VALUES (1, 1, 1, SYSDATE, NULL, 'zapisany', 0);
INSERT INTO Zapisy VALUES (1, 2, 4, SYSDATE, NULL, 'zapisany', 0);
INSERT INTO Zapisy VALUES (2, 1, 3, SYSDATE, NULL, 'zapisany', 0);
INSERT INTO Zapisy VALUES (3, 1, 5, SYSDATE, NULL, 'zapisany', 0);
INSERT INTO Zapisy VALUES (4, 1, 1, SYSDATE, NULL, 'zapisany', 0); -- Ewa na Podstawy programowania
INSERT INTO Zapisy VALUES (4, 2, 2, SYSDATE, NULL, 'zapisany', 0); -- Ewa na Bazy danych
INSERT INTO Zapisy VALUES (5, 1, 3, SYSDATE, NULL, 'zapisany', 0); -- Tomasz na Analiza matematyczna
INSERT INTO Zapisy VALUES (5, 2, 1, SYSDATE, NULL, 'zapisany', 0); -- Tomasz na Podstawy programowania
INSERT INTO Zapisy VALUES (6, 1, 5, SYSDATE, NULL, 'zapisany', 0); -- Katarzyna na Fizyka ogólna
INSERT INTO Zapisy VALUES (6, 2, 4, SYSDATE, NULL, 'zapisany', 0); -- Katarzyna na Algorytmy i struktury danych

-- ===================================
-- Przykładowe operacje
-- ===================================

-- 1. Zapis studenta na nowy przedmiot
INSERT INTO Zapisy VALUES (1, 3, 2, SYSDATE, NULL, 'zapisany', 0);

-- Sprawdzenie limitu miejsc (w rzeczywistej aplikacji byłby trigger)
UPDATE Przedmioty 
SET Limit_studentow = Limit_studentow - 1 
WHERE ID_przedmiotu = 2 AND Limit_studentow > 0;

-- 2. Wystawienie oceny końcowej i zaliczenie przedmiotu
UPDATE Zapisy 
SET Ocena_koncowa = 5, 
    Status_zapisu = 'zaliczony',
    Punkty_ECTS_uzyskane = (SELECT Punkty_ECTS FROM Przedmioty WHERE ID_przedmiotu = 1)
WHERE ID_student_semestr = 1 AND ID_zapisu = 1;

-- 3. Rezygnacja z przedmiotu
UPDATE Zapisy 
SET Status_zapisu = 'rezygnacja' 
WHERE ID_student_semestr = 1 AND ID_zapisu = 3;

-- Przywrócenie miejsca
UPDATE Przedmioty 
SET Limit_studentow = Limit_studentow + 1 
WHERE ID_przedmiotu = 2;

-- Student nie zalicza przedmiotu (np. Adam Mickiewicz, ID_student_semestr = 1, ID_zapisu = 1)
UPDATE Zapisy
SET Ocena_koncowa = 2, Status_zapisu = 'niezaliczony', Punkty_ECTS_uzyskane = 0
WHERE ID_student_semestr = 1 AND ID_zapisu = 1;

-- Ewa zalicza Bazy danych
UPDATE Zapisy 
SET Ocena_koncowa = 4, Status_zapisu = 'zaliczony', 
    Punkty_ECTS_uzyskane = (SELECT Punkty_ECTS FROM Przedmioty WHERE ID_przedmiotu = 2)
WHERE ID_student_semestr = 4 AND ID_zapisu = 2;

-- Tomasz rezygnuje z Podstaw programowania
UPDATE Zapisy 
SET Status_zapisu = 'rezygnacja'
WHERE ID_student_semestr = 5 AND ID_zapisu = 2;

-- Katarzyna zalicza Fizyka ogólna
UPDATE Zapisy 
SET Ocena_koncowa = 5, Status_zapisu = 'zaliczony', 
    Punkty_ECTS_uzyskane = (SELECT Punkty_ECTS FROM Przedmioty WHERE ID_przedmiotu = 5)
WHERE ID_student_semestr = 6 AND ID_zapisu = 1;


-- Dodanie oceny cząstkowej dla studenta (np. Adam Mickiewicz, ID_student_semestr = 1, ID_zapisu = 1)
INSERT INTO Oceny_czastkowe (ID_oceny, ID_student_semestr, ID_zapisu, Rodzaj_oceny, Ocena, Data_wystawienia, Waga)
VALUES (1, 1, 1, 'Kolokwium 1', 4, SYSDATE, 0.4);

-- Dodanie kolejnej oceny cząstkowej dla tego samego zapisu
INSERT INTO Oceny_czastkowe (ID_oceny, ID_student_semestr, ID_zapisu, Rodzaj_oceny, Ocena, Data_wystawienia, Waga)
VALUES (2, 1, 1, 'Projekt', 5, SYSDATE, 0.6);

-- ===================================
-- Przykładowe zapytania
-- ===================================

-- 1. Lista wszystkich zapisów studentów z nazwami przedmiotów i wykładowców
SELECT S.Imie || ' ' || S.Nazwisko AS Student, 
       S.Nr_albumu,
       P.Nazwa_przedmiotu, 
       P.Kod_przedmiotu,
       W.Tytul || ' ' || W.Imie || ' ' || W.Nazwisko AS Wykladowca,
       Z.Status_zapisu,
       Z.Ocena_koncowa
FROM Zapisy Z
JOIN Student_Semestr SS ON Z.ID_student_semestr = SS.ID_student_semestr
JOIN Studenci S ON SS.ID_studenta = S.ID_studenta
JOIN Przedmioty P ON Z.ID_przedmiotu = P.ID_przedmiotu
JOIN Wykladowcy W ON P.ID_wykladowcy = W.ID_wykladowcy
ORDER BY S.Nazwisko, P.Nazwa_przedmiotu;

-- 2. Średnia ocen każdego studenta
SELECT S.Imie, S.Nazwisko, S.Nr_albumu,
       ROUND(AVG(Z.Ocena_koncowa), 2) AS Srednia_ocen,
       SUM(Z.Punkty_ECTS_uzyskane) AS Suma_ECTS
FROM Studenci S
JOIN Student_Semestr SS ON S.ID_studenta = SS.ID_studenta
JOIN Zapisy Z ON SS.ID_student_semestr = Z.ID_student_semestr
WHERE Z.Ocena_koncowa IS NOT NULL
GROUP BY S.ID_studenta, S.Imie, S.Nazwisko, S.Nr_albumu
ORDER BY Srednia_ocen DESC;

-- 3. Liczba studentów zapisanych na każdy przedmiot
SELECT P.Kod_przedmiotu, P.Nazwa_przedmiotu, 
       COUNT(Z.ID_zapisu) AS Liczba_zapisanych,
       P.Limit_studentow,
       P.Limit_studentow - COUNT(Z.ID_zapisu) AS Wolne_miejsca
FROM Przedmioty P
LEFT JOIN Zapisy Z ON P.ID_przedmiotu = Z.ID_przedmiotu AND Z.Status_zapisu = 'zapisany'
GROUP BY P.ID_przedmiotu, P.Kod_przedmiotu, P.Nazwa_przedmiotu, P.Limit_studentow
ORDER BY Liczba_zapisanych DESC;

-- 4. Studenci z niezaliczonymi przedmiotami
SELECT S.Imie, S.Nazwisko, S.Nr_albumu, P.Nazwa_przedmiotu, Z.Ocena_koncowa
FROM Studenci S
JOIN Student_Semestr SS ON S.ID_studenta = SS.ID_studenta
JOIN Zapisy Z ON SS.ID_student_semestr = Z.ID_student_semestr
JOIN Przedmioty P ON Z.ID_przedmiotu = P.ID_przedmiotu
WHERE Z.Status_zapisu = 'niezaliczony' OR (Z.Status_zapisu = 'zapisany' AND SS.Status = 'zaliczony')
ORDER BY S.Nazwisko;

-- 5. Statystyki ocen dla każdego przedmiotu
SELECT P.Nazwa_przedmiotu,
       COUNT(CASE WHEN Z.Ocena_koncowa = 5 THEN 1 END) AS "Bardzo dobry",
       COUNT(CASE WHEN Z.Ocena_koncowa = 4 THEN 1 END) AS "Dobry",
       COUNT(CASE WHEN Z.Ocena_koncowa = 3 THEN 1 END) AS "Dostateczny",
       COUNT(CASE WHEN Z.Ocena_koncowa = 2 THEN 1 END) AS "Niedostateczny",
       ROUND(AVG(Z.Ocena_koncowa), 2) AS "Średnia ocen"
FROM Przedmioty P
LEFT JOIN Zapisy Z ON P.ID_przedmiotu = Z.ID_przedmiotu
WHERE Z.Ocena_koncowa IS NOT NULL
GROUP BY P.ID_przedmiotu, P.Nazwa_przedmiotu
ORDER BY "Średnia ocen" DESC;

-- 6. Oceny cząstkowe dla każdego przedmiotu

SELECT S.Imie, S.Nazwisko, P.Nazwa_przedmiotu, OC.Rodzaj_oceny, OC.Ocena, OC.Waga, OC.Data_wystawienia
FROM Oceny_czastkowe OC
JOIN Zapisy Z ON OC.ID_student_semestr = Z.ID_student_semestr AND OC.ID_zapisu = Z.ID_zapisu
JOIN Student_Semestr SS ON Z.ID_student_semestr = SS.ID_student_semestr
JOIN Studenci S ON SS.ID_studenta = S.ID_studenta
JOIN Przedmioty P ON Z.ID_przedmiotu = P.ID_przedmiotu
WHERE OC.Ocena IS NOT NULL
ORDER BY OC.Data_wystawienia;


COMMIT;

SELECT table_name
FROM user_tables
WHERE table_name IN ('STUDENCI', 'PRZEDMIOTY', 'SEMESTRY', 'ZAPISY', 'KIERUNKI', 'WYKLADOWCY', 'OCENY_CZASTKOWE', 'STUDENT_SEMESTR')
ORDER BY table_name;