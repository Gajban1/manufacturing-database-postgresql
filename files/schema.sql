CREATE DATABASE company;

\c company

CREATE TABLE pracownicy (
    pracownik_id INTEGER PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    pesel VARCHAR(11) UNIQUE NOT NULL,
    data_urodzenia DATE NOT NULL,
    adres VARCHAR(255),
    telefon_kontaktowy VARCHAR(15) UNIQUE,
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
    telefon VARCHAR(15) UNIQUE,
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



CREATE TABLE katalog_wykroczen (
    wykroczenie_id INTEGER PRIMARY KEY,
    nazwa_wykroczenia VARCHAR(100) UNIQUE NOT NULL,
    opis VARCHAR(255),
    standardowa_kara_pln NUMERIC(8,2) NOT NULL
);



CREATE TABLE rejestr_wykroczen (
    rejestr_wykroczenia_id INTEGER PRIMARY KEY,
    pracownik_id INTEGER NOT NULL,
    wykroczenie_id INTEGER NOT NULL,
    data_zdarzenia DATE NOT NULL,
    naliczona_kara NUMERIC(8,2) NOT NULL,
    opis_zdarzenia VARCHAR(500)
);


CREATE TABLE klienci (
    klient_id INTEGER PRIMARY KEY,
    nazwa_klienta VARCHAR(100) UNIQUE NOT NULL,
    adres VARCHAR(255),
    nip VARCHAR(10) UNIQUE,
    telefon_kontaktowy VARCHAR(15),
    email_kontaktowy VARCHAR(100),
    osoba_kontaktowa VARCHAR(100)
);


CREATE TABLE zlecenia_produkcyjne (
    zlecenie_id INTEGER PRIMARY KEY,
    klient_id INTEGER NOT NULL,
    numer_zlecenia_klienta VARCHAR(50) UNIQUE NOT NULL,
    data_przyjecia_zlecenia DATE NOT NULL,
    przewidywana_data_realizacji DATE NOT NULL,
    data_faktycznej_realizacji DATE,
    nazwa_produktu VARCHAR(255) NOT NULL,
    ilosc INTEGER NOT NULL,
    cena_jednostkowa NUMERIC(10,2) NOT NULL,
    waluta VARCHAR(3) NOT NULL,
    jednostka_id INTEGER NOT NULL,
    opis_zlecenia VARCHAR(500),
    czy_zakonczona BOOLEAN DEFAULT FALSE NOT NULL
);

ALTER TABLE pracownicy 
ADD CONSTRAINT fk_przelozony_id_pracownicy
FOREIGN KEY (przelozony_id) 
REFERENCES pracownicy(pracownik_id);

ALTER TABLE pracownicy 
ADD CONSTRAINT fk_jednostka_id_pracownicy
FOREIGN KEY (jednostka_id) 
REFERENCES jednostki_organizacyjne(jednostka_id);


ALTER TABLE jednostki_organizacyjne 
ADD CONSTRAINT fk_jednostka_nadrzedna_id_jednostki_org
FOREIGN KEY (jednostka_nadrzedna_id) 
REFERENCES jednostki_organizacyjne(jednostka_id);


ALTER TABLE rejestr_czasu_pracy
ADD CONSTRAINT fk_pracownik_id_rejestr_pracy
FOREIGN KEY (pracownik_id) 
REFERENCES pracownicy(pracownik_id);


ALTER TABLE wynagrodzenia 
ADD CONSTRAINT fk_pracownik_id_wynagrodzenia
FOREIGN KEY (pracownik_id) 
REFERENCES pracownicy(pracownik_id);


ALTER TABLE rejestr_wykroczen 
ADD CONSTRAINT fk_jednostka_id_rejestr_wykroczen
FOREIGN KEY (pracownik_id) 
REFERENCES pracownicy(pracownik_id);


ALTER TABLE rejestr_wykroczen 
ADD CONSTRAINT fk_wykroczenie_id_rejestr_wykroczen
FOREIGN KEY (wykroczenie_id) 
REFERENCES katalog_wykroczen(wykroczenie_id);


ALTER TABLE zlecenia_produkcyjne 
ADD CONSTRAINT fk_klient_id_rejestr_wykroczen
FOREIGN KEY (klient_id) 
REFERENCES klienci(klient_id);


ALTER TABLE zlecenia_produkcyjne 
ADD CONSTRAINT fk_jednostka_id_rejestr_wykroczen
FOREIGN KEY (jednostka_id) 
REFERENCES jednostki_organizacyjne(jednostka_id);