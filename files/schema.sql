CREATE DATABASE company;

\c company

CREATE TABLE pracownicy (
    pracownik_id INTEGER PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    pesel VARCHAR(11) UNIQUE NOT NULL,
    data_urodzenia DATE NOT NULL,
    adres VARCHAR(255),
    telefon_kontaktowy VARCHAR(15),
    email_sluzbowy VARCHAR(100) UNIQUE,
    stanowisko VARCHAR(100) NOT NULL,
    jednostka_id INTEGER NOT NULL,
    data_zatrudnienia DATE NOT NULL,
    data_zwolnienia DATE,
    typ_umowy VARCHAR(50) NOT NULL,
    wymiar_etatu NUMERIC(3,2) NOT NULL,
    numer_konta_bankowego VARCHAR(26) UNIQUE,
    przelozony_id INTEGER,
    aktywny BOOLEAN DEFAULT TRUE NOT NULL
);


CREATE TABLE jednostki_organizacyjne (
    jednostka_id INTEGER PRIMARY KEY,
    nazwa_jednostki VARCHAR(100) UNIQUE NOT NULL,
    typ_jednostki VARCHAR(20) NOT NULL,
    adres VARCHAR(255),
    telefon VARCHAR(15),
    jednostka_nadrzedna_id INTEGER
);

CREATE TABLE rejestr_czasu_pracy (
    rejestr_id INTEGER PRIMARY KEY,
    pracownik_id INTEGER NOT NULL,
    data_pracy DATE NOT NULL,
    godziny_przepracowane NUMERIC(4,2) NOT NULL,
    godziny_nadliczbowe NUMERIC(4,2) DEFAULT 0.00 NOT NULL
);

CREATE TABLE wynagrodzenia (
    wynagrodzenie_id INTEGER PRIMARY KEY,
    pracownik_id INTEGER NOT NULL,
    okres_rozliczeniowy DATE NOT NULL,
    data_wyplaty DATE NOT NULL,
    placa_podstawowa NUMERIC(10,2) NOT NULL,
    premia_za_wyniki NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    dodatek_za_nadgodziny NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    kary_za_wykroczenia NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    calkowite_wynagrodzenie_brutto NUMERIC(10,2) NOT NULL,
    calkowite_wynagrodzenie_netto NUMERIC(10,2) NOT NULL,
    komentarz VARCHAR(255)
);
