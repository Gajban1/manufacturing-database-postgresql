-- Transactional regression checks. Run against a fresh disposable schema.
BEGIN;
INSERT INTO jednostki_organizacyjne (jednostka_id,nazwa_jednostki,typ_jednostki) VALUES (900001,'Test department','Dział');
INSERT INTO pracownicy (pracownik_id,imie,nazwisko,pesel,data_urodzenia,stanowisko,jednostka_id,data_zatrudnienia,typ_umowy,wymiar_etatu,stawka_godzinowa)
VALUES (900001,'Test','Employee','44051401458','1944-05-14','Tester',900001,CURRENT_DATE,'Test',1,30);
DO $$ BEGIN
  BEGIN
    UPDATE pracownicy SET pesel='44051401459' WHERE pracownik_id=900001;
    RAISE EXCEPTION 'test_failed_invalid_pesel';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM = 'test_failed_invalid_pesel' THEN RAISE; END IF;
  END;
END $$;
INSERT INTO wynagrodzenia (wynagrodzenie_id,pracownik_id,okres_rozliczeniowy,data_wyplaty,placa_podstawowa,calkowite_wynagrodzenie_brutto,calkowite_wynagrodzenie_netto)
VALUES (900001,900001,CURRENT_DATE,CURRENT_DATE,100,100,70), (900002,900001,CURRENT_DATE-60,CURRENT_DATE-60,100,100,70);
UPDATE wynagrodzenia SET komentarz='allowed recent update' WHERE wynagrodzenie_id=900001;
DO $$ BEGIN
  IF (SELECT komentarz FROM wynagrodzenia WHERE wynagrodzenie_id=900001) IS DISTINCT FROM 'allowed recent update' THEN
    RAISE EXCEPTION 'Recent payroll update was silently discarded';
  END IF;
  BEGIN
    UPDATE wynagrodzenia SET komentarz='blocked' WHERE wynagrodzenie_id=900002;
    RAISE EXCEPTION 'test_failed_old_update';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM = 'test_failed_old_update' THEN RAISE; END IF;
  END;
  BEGIN
    DELETE FROM wynagrodzenia WHERE wynagrodzenie_id=900002;
    RAISE EXCEPTION 'test_failed_old_delete';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM = 'test_failed_old_delete' THEN RAISE; END IF;
  END;
END $$;
ROLLBACK;
