
-- nie wiem czy tak to wlasnie mialo dzialac, ale jak mozesz to dodaj jakies nowe funkcje bo nie wiem co mam dalej robic

CREATE OR REPLACE FUNCTION show_salary(emp_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_pay NUMERIC := 0;
    bonus_total NUMERIC := 0;
    emp_status VARCHAR(30);
BEGIN
    SELECT status 
    INTO emp_status
    FROM employee_register
    WHERE employee_id = emp_id
    ORDER BY register_date DESC
    LIMIT 1;

    IF emp_status IS NULL OR LOWER(emp_status) <> 'aktywny' THEN
        RAISE NOTICE 'Pracownik % nie jest aktywny lub nie istnieje.', emp_id;
        RETURN 0;
    END IF;


    SELECT COALESCE(SUM(hours_worked * hourly_rate), 0)
    INTO total_pay
    FROM work_hours
    WHERE employee_id = emp_id;


    SELECT COALESCE(SUM(bonus_value), 0)
    INTO bonus_total
    FROM bonus_points
    WHERE employee_id = emp_id;

    RETURN total_pay + bonus_total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE generuj_wyplaty_za_miesiac(rok INT, miesiac INT)
LANGUAGE plpgsql AS $$
DECLARE
    -- Pobieramy rekord pracownika (w tym jego stawkę)
    pracownik RECORD;
    
    suma_godzin NUMERIC(10,2);
    suma_kar NUMERIC(10,2);
    wyplata_brutto NUMERIC(10,2);
    nowe_id INTEGER;
    start_date DATE;
    end_date DATE;
BEGIN
    start_date := MAKE_DATE(rok, miesiac, 1);
    end_date := (start_date + INTERVAL '1 month' - INTERVAL '1 day')::DATE;

    RAISE NOTICE 'Generowanie listy płac za okres: % - %', start_date, end_date;

    -- Pętla po pracownikach (pobieramy stawkę bezpośrednio stąd)
    FOR pracownik IN SELECT * FROM pracownicy WHERE aktywny = TRUE LOOP
        
        -- 1. Policz godziny
        SELECT COALESCE(SUM(godziny_przepracowane), 0) INTO suma_godzin
        FROM rejestr_czasu_pracy
        WHERE pracownik_id = pracownik.pracownik_id 
          AND data_pracy BETWEEN start_date AND end_date;

        -- 2. Policz kary
        SELECT COALESCE(SUM(naliczona_kara), 0) INTO suma_kar
        FROM rejestr_wykroczen
        WHERE pracownik_id = pracownik.pracownik_id 
          AND data_zdarzenia BETWEEN start_date AND end_date;

        -- 3. Oblicz (Używamy pracownik.stawka_godzinowa z tabeli pracownicy)
        wyplata_brutto := (suma_godzin * pracownik.stawka_godzinowa) - suma_kar;

        IF suma_godzin = 0 AND suma_kar = 0 THEN
            CONTINUE;
        END IF;

        -- 4. Zapisz wynik
        SELECT COALESCE(MAX(wynagrodzenie_id), 0) + 1 INTO nowe_id FROM wynagrodzenia;

        INSERT INTO wynagrodzenia (
            wynagrodzenie_id, 
            pracownik_id, 
            okres_rozliczeniowy, 
            data_wyplaty, 
            placa_podstawowa, 
            calkowite_wynagrodzenie_brutto, 
            calkowite_wynagrodzenie_netto,
            kary_za_wykroczenia
        ) VALUES (
            nowe_id,
            pracownik.pracownik_id,
            end_date,
            CURRENT_DATE,
            (suma_godzin * pracownik.stawka_godzinowa),
            wyplata_brutto,
            wyplata_brutto * 0.70,
            suma_kar
        );
        
        RAISE NOTICE 'Pracownik % %: %h * % PLN = % PLN', 
            pracownik.imie, pracownik.nazwisko, suma_godzin, pracownik.stawka_godzinowa, wyplata_brutto;
        
    END LOOP;
END;
$$;

----------------------------------------------------
-- 3. TRIGGER: Walidacja PESEL i Telefonu (Pracownicy)
----------------------------------------------------

CREATE OR REPLACE FUNCTION waliduj_dane_pracownika()
RETURNS TRIGGER AS $$
DECLARE
    -- Zmienne do obliczania PESEL
    p_vector int[] := ARRAY[1, 3, 7, 9, 1, 3, 7, 9, 1, 3]; -- Wagi
    p_sum int := 0;
    p_digit int;
    control_digit int;
    i int;
BEGIN
    ---------------------------------------------
    -- A. Walidacja Telefonu (jeśli podany)
    ---------------------------------------------
    IF NEW.telefon_kontaktowy IS NOT NULL THEN
        -- Sprawdź czy telefon ma min. 9 znaków i składa się tylko z cyfr, spacji, -, +
        IF NOT NEW.telefon_kontaktowy ~ '^[0-9+ -]{9,15}$' THEN
            RAISE EXCEPTION 'Błąd: Numer telefonu (%) ma nieprawidłowy format.', NEW.telefon_kontaktowy;
        END IF;
    END IF;

    ---------------------------------------------
    -- B. Walidacja PESEL
    ---------------------------------------------
    -- 1. Sprawdź długość (musi być 11 znaków i same cyfry)
    IF NOT NEW.pesel ~ '^[0-9]{11}$' THEN
        RAISE EXCEPTION 'Błąd: PESEL (%) musi składać się z dokładnie 11 cyfr.', NEW.pesel;
    END IF;

    -- 2. Sprawdź Sumę Kontrolną (Algorytm Wagowy)
    -- Pętla przez pierwsze 10 cyfr
    FOR i IN 1..10 LOOP
        -- Wyciągamy cyfrę i mnożymy przez wagę
        p_digit := CAST(SUBSTR(NEW.pesel, i, 1) AS INTEGER);
        p_sum := p_sum + (p_digit * p_vector[i]);
    END LOOP;

    -- Obliczamy cyfrę kontrolną: (10 - (suma modulo 10)) modulo 10
    control_digit := (10 - (p_sum % 10)) % 10;

    -- Porównujemy z 11. cyfrą PESELu
    IF control_digit <> CAST(SUBSTR(NEW.pesel, 11, 1) AS INTEGER) THEN
        RAISE EXCEPTION 'Błąd: Nieprawidłowy PESEL (%). Zła suma kontrolna.', NEW.pesel;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Podpięcie triggera pod tabelę pracownicy
DROP TRIGGER IF EXISTS trigger_validate_pracownik ON pracownicy;

CREATE TRIGGER trigger_validate_pracownik
BEFORE INSERT OR UPDATE ON pracownicy
FOR EACH ROW
EXECUTE FUNCTION waliduj_dane_pracownika();

-- Raport: Średnie zarobki i koszty w podziale na działy
CREATE OR REPLACE VIEW raport_koszty_dzialow AS
SELECT 
    j.nazwa_jednostki AS dzial,
    COUNT(p.pracownik_id) AS liczba_pracownikow,
    COALESCE(SUM(w.calkowite_wynagrodzenie_brutto), 0) AS suma_wyplat_brutto,
    ROUND(AVG(w.calkowite_wynagrodzenie_brutto), 2) AS srednia_wyplata
FROM jednostki_organizacyjne j
LEFT JOIN pracownicy p ON j.jednostka_id = p.jednostka_id
LEFT JOIN wynagrodzenia w ON p.pracownik_id = w.pracownik_id
-- Bierzemy pod uwagę tylko wypłaty z bieżącego roku (opcjonalnie)
WHERE w.data_wyplaty >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY j.nazwa_jednostki
ORDER BY suma_wyplat_brutto DESC;

----------------------------------------------------
-- 4. FUNKCJA: Raport finansowy zakończonych zleceń
----------------------------------------------------
CREATE OR REPLACE FUNCTION pobierz_raport_zlecen(p_rok INT, p_miesiac INT)
RETURNS TABLE (
    klient VARCHAR,
    numer_zlecenia VARCHAR,
    produkt VARCHAR,
    data_zakonczenia DATE,
    ilosc INT,
    kwota_zarobiona NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        k.nazwa_klienta,
        z.numer_zlecenia_klienta,
        z.nazwa_produktu,
        z.data_faktycznej_realizacji,
        z.ilosc,
        (z.ilosc * z.cena_jednostkowa) AS kwota_zarobiona
    FROM zlecenia_produkcyjne z
    JOIN klienci k ON z.klient_id = k.klient_id
    WHERE 
        z.czy_zakonczona = TRUE
        AND EXTRACT(YEAR FROM z.data_faktycznej_realizacji) = p_rok
        AND EXTRACT(MONTH FROM z.data_faktycznej_realizacji) = p_miesiac
    ORDER BY z.data_faktycznej_realizacji ASC;
END;
$$ LANGUAGE plpgsql;