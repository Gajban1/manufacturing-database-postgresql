-- =============================================
-- SKRYPT ZARZĄDZANIA ROLAMI I UPRAWNIENIAMI
-- System: Masowe Dane
-- Data: 2025-12-22
-- =============================================

-- 1. Tworzenie Ról (Grup Użytkowników)
---------------------------------------------
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'role_admin') THEN CREATE ROLE role_admin NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'role_hr_manager') THEN CREATE ROLE role_hr_manager NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'role_production_manager') THEN CREATE ROLE role_production_manager NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'role_accountant') THEN CREATE ROLE role_accountant NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'role_readonly') THEN CREATE ROLE role_readonly NOLOGIN; END IF;
END $$;

-- 2. Nadawanie Uprawnień (GRANTS)
---------------------------------------------

-- === Rola: role_admin ===
-- Pełna władza nad schematem public
GRANT ALL ON SCHEMA public TO role_admin;
GRANT ALL ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO role_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO role_admin;
GRANT ALL ON ALL PROCEDURES IN SCHEMA public TO role_admin;


-- === Rola: role_hr_manager (Kadry i Płace) ===
GRANT USAGE ON SCHEMA public TO role_hr_manager;

-- Zarządzanie pracownikami i czasem pracy (Pełny dostęp)
GRANT SELECT, INSERT, UPDATE ON TABLE public.pracownicy TO role_hr_manager;
GRANT USAGE ON SEQUENCE public.pracownicy_pracownik_id_seq TO role_hr_manager;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.rejestr_czasu_pracy TO role_hr_manager;
GRANT USAGE ON SEQUENCE public.rejestr_czasu_pracy_rejestr_id_seq TO role_hr_manager;

GRANT SELECT, INSERT, UPDATE ON TABLE public.rejestr_wykroczen TO role_hr_manager;
GRANT USAGE ON SEQUENCE public.rejestr_wykroczen_id_seq TO role_hr_manager; 
-- (Assuming id seq name, fallback to generic if specific known)

-- Płace (Tylko dodawanie nowych list, bez usuwania historii)
GRANT SELECT, INSERT ON TABLE public.wynagrodzenia TO role_hr_manager;
GRANT USAGE ON SEQUENCE public.wynagrodzenia_wynagrodzenie_id_seq TO role_hr_manager;

-- Procedury biznesowe
GRANT EXECUTE ON PROCEDURE public.generuj_wyplaty_za_miesiac TO role_hr_manager;
GRANT EXECUTE ON PROCEDURE public.archiwizuj_pracownika TO role_hr_manager;
GRANT EXECUTE ON FUNCTION public.show_salary TO role_hr_manager;
GRANT EXECUTE ON FUNCTION public.oblicz_efektywnosc_pracownika TO role_hr_manager;

-- Słowniki (Odczyt)
GRANT SELECT ON TABLE public.jednostki_organizacyjne TO role_hr_manager;
GRANT SELECT ON TABLE public.katalog_wykroczen TO role_hr_manager;


-- === Rola: role_production_manager (Produkcja) ===
GRANT USAGE ON SCHEMA public TO role_production_manager;

-- Zarządzanie zleceniami
GRANT SELECT, INSERT, UPDATE ON TABLE public.zlecenia_produkcyjne TO role_production_manager;
GRANT USAGE ON SEQUENCE public.zlecenia_produkcyjne_zlecenie_id_seq TO role_production_manager;

-- CRM (Klienci)
GRANT SELECT, INSERT, UPDATE ON TABLE public.klienci TO role_production_manager;
GRANT USAGE ON SEQUENCE public.klienci_klient_id_seq TO role_production_manager;

-- Narzędzia analityczne
GRANT EXECUTE ON FUNCTION public.przewidz_termin_realizacji TO role_production_manager;
GRANT EXECUTE ON FUNCTION public.pobierz_raport_zlecen TO role_production_manager;
GRANT EXECUTE ON FUNCTION public.prognoza_przychodow TO role_production_manager;

-- Podgląd (Ograniczony)
GRANT SELECT(imie, nazwisko, stanowisko) ON TABLE public.pracownicy TO role_production_manager;
GRANT SELECT ON TABLE public.jednostki_organizacyjne TO role_production_manager;


-- === Rola: role_accountant (Księgowość) ===
GRANT USAGE ON SCHEMA public TO role_accountant;

-- Tylko odczyt danych finansowych
GRANT SELECT ON TABLE public.wynagrodzenia TO role_accountant;
GRANT SELECT ON TABLE public.zlecenia_produkcyjne TO role_accountant;
GRANT SELECT ON TABLE public.klienci TO role_accountant;
GRANT SELECT ON TABLE public.raport_koszty_dzialow TO role_accountant; -- Widok
GRANT SELECT ON TABLE public.pracownicy TO role_accountant; -- (Potrzebne do kontekstu płac)


-- === Rola: role_readonly (Audyt) ===
GRANT USAGE ON SCHEMA public TO role_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_readonly;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO role_readonly;
