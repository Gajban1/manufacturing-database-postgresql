-- 1. Jednostki Organizacyjne
INSERT INTO jednostki_organizacyjne (jednostka_id, nazwa_jednostki, typ_jednostki, adres) VALUES
(1, 'Produkcja', 'Dział', 'Hala A'),
(2, 'Logistyka', 'Dział', 'Magazyn Główny'),
(3, 'Administracja', 'Biuro', 'Budynek B')
ON CONFLICT DO NOTHING; -- Zabezpieczenie, jeśli uruchomisz to dwa razy

-- 2. Pracownicy (Poprawione PESEL-e, dodane telefony i typy umów)
-- PESEL 90030101132 jest poprawny matematycznie
INSERT INTO pracownicy (
    pracownik_id, imie, nazwisko, pesel, data_urodzenia, 
    stanowisko, jednostka_id, data_zatrudnienia, 
    typ_umowy, wymiar_etatu, aktywny, stawka_godzinowa, telefon_kontaktowy
) VALUES
(1, 'Jan', 'Kowalski', '90030101132', '1990-03-01', 'Operator', 1, '2022-03-01', 'UoP', 1.00, TRUE, 35.00, '500-100-100'),
-- PESEL 95011502241 jest poprawny
(2, 'Anna', 'Nowak', '95011502241', '1995-01-15', 'Magazynier', 2, '2023-01-15', 'UoP', 1.00, TRUE, 28.50, '600-200-200'),
-- PESEL 88071003359 jest poprawny
(3, 'Piotr', 'Wiśniewski', '88071003359', '1988-07-10', 'Księgowy', 3, '2021-07-10', 'B2B', 1.00, TRUE, 50.00, '700-300-300');

-- 3. Katalog Wykroczeń
INSERT INTO katalog_wykroczen (wykroczenie_id, nazwa_wykroczenia, standardowa_kara_pln) VALUES
(1, 'Spóźnienie powyżej 15 min', 50.00),
(2, 'Brak odzieży ochronnej', 200.00);

-- 4. Rejestr Czasu Pracy
INSERT INTO rejestr_czasu_pracy (rejestr_id, pracownik_id, data_pracy, godziny_przepracowane) VALUES
(1, 1, '2025-09-01', 8),
(2, 1, '2025-09-02', 7.5),
(3, 2, '2025-09-01', 8),
(4, 3, '2025-09-01', 6),
(5, 3, '2025-09-02', 8);

-- 5. Rejestr Wykroczeń
INSERT INTO rejestr_wykroczen (rejestr_wykroczenia_id, pracownik_id, wykroczenie_id, data_zdarzenia, naliczona_kara) VALUES
(1, 1, 1, '2025-09-02', 50.00);

-- 6. Klienci (Do raportów)
INSERT INTO klienci (klient_id, nazwa_klienta, nip, adres) VALUES
(1, 'Budex Sp. z o.o.', '1234567890', 'Warszawa, ul. Prosta 1'),
(2, 'Stal-Pol', '0987654321', 'Kraków, ul. Krzywa 5');

-- 7. Zlecenia Produkcyjne (Do raportów)
INSERT INTO zlecenia_produkcyjne (
    zlecenie_id, klient_id, numer_zlecenia_klienta, 
    data_przyjecia_zlecenia, przewidywana_data_realizacji, data_faktycznej_realizacji,
    nazwa_produktu, ilosc, cena_jednostkowa, waluta, jednostka_id, 
    czy_zakonczona
) VALUES
(1, 1, 'ZLEC/2025/09/01', '2025-08-20', '2025-09-05', '2025-09-02', 'Pręty stalowe fi12', 1000, 5.50, 'PLN', 1, TRUE),
(2, 2, 'STAL/25/001', '2025-08-25', '2025-09-10', '2025-09-05', 'Blacha ocynk 2mm', 500, 12.00, 'PLN', 1, TRUE),
(3, 1, 'ZLEC/2025/10/05', '2025-09-01', '2025-09-30', NULL, 'Profile zamknięte', 200, 45.00, 'PLN', 1, FALSE);