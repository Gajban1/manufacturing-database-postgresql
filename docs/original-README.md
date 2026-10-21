> Historical academic documentation. Some scope and security claims are aspirational; see the current README for implemented scope and limitations. This was not a commercial deployment.

# Projekt Bazy Danych: System Zarządzania dla Wielton S.A.

### Kontekst Biznesowy

Projekt realizowany jest dla firmy **Wielton S.A.**, czołowego międzynarodowego producenta naczep i przyczep do ciągników siodłowych. Firma, z głównymi zakładami w Wieluniu i Bełchatowie, działa na zlecenie globalnych klientów, takich jak Amazon czy Lawrence David, zatrudniając ponad 3000 pracowników w całej Europie.

*Nazwa "Maxczep S.A." jest używana jako fikcyjny odpowiednik na potrzeby tego projektu.*

Celem projektu jest stworzenie zintegrowanej bazy danych w technologii **PostgreSQL**, która usprawni zarządzanie kluczowymi obszarami działalności firmy: od zasobów ludzkich (HR), przez ewidencję czasu pracy i wynagrodzeń, po monitorowanie zleceń produkcyjnych i zgodności z zasadami BHP.

### Technologia

*   **System Zarządzania Bazą Danych (SZBD):** PostgreSQL

### Główne Moduły Bazy Danych

System został podzielony na logiczne, powiązane ze sobą moduły:

#### 1. Moduł Kadr i Płac (HR & Payroll)
*   **Ewidencja Pracowników:** Centralna baza danych przechowująca szczegółowe informacje o pracownikach (dane osobowe, warunki zatrudnienia, stawkę godzinową).
*   **Rejestracja Czasu Pracy:** Moduł do zapisywania godzin pracy i nadgodzin, stanowiący podstawę do naliczania wynagrodzeń.
*   **Zarządzanie Wynagrodzeniami:** Automatyczne generowanie list płac na podstawie RCP i stawek, z uwzględnieniem potrąceń za kary dyscyplinarne.

#### 2. Moduł Operacyjny i Produkcyjny
*   **Zarządzanie Zleceniami:** Śledzenie zleceń produkcyjnych od klientów, ich statusu, przypisanych zespołów oraz postępów w realizacji.
*   **Ewidencja Zasobów:** Baza do ewidencji kluczowych zasobów firmy. *(Zakres do uszczegółowienia, np. ewidencja maszyn, narzędzi, gotowych produktów).*

#### 3. Moduł Dyscypliny
*   **System Kar Finansowych:** Rejestr wykroczeń powiązany bezpośrednio z systemem płacowym. Wykroczenia (zdefiniowane w katalogu) skutkują automatycznym naliczeniem kary finansowej potrącanej z najbliższej wypłaty.

---

### Lista Funkcji Bazy Danych

Baza danych zostanie wyposażona w logikę (w postaci funkcji, widoków i procedur składowanych), która umożliwi realizację następujących operacji:

*   **Generowanie Płac:** Procedura `generuj_wyplaty_za_miesiac(rok, miesiac)` automatycznie obliczająca wynagrodzenie netto/brutto dla wszystkich pracowników na podstawie RCP i kar.
*   **Estymacja Produkcji:** Funkcja `przewidz_termin_realizacji(ilosc, typ)` wyliczająca przewidywaną datę zakończenia zlecenia w oparciu o typ produktu i moce przerobowe.
*   **Analityka HR (ROI):** Funkcja `oblicz_efektywnosc_pracownika(id, miesiac)` mierząca efektywność finansową pracownika (stosunek kosztów zatrudnienia do wygenerowanego przychodu).
*   **Prognozowanie Przychodów:** Funkcja `prognoza_przychodow` przewidująca wpływy w najbliższych miesiącach na podstawie historycznych danych sprzedażowych.
*   **Walidacja Danych:** Wyzwalacze (Triggers) dbalące o poprawność danych, np. walidacja numeru PESEL algorytmem wagowym (`trigger_validate_pracownik`).

---

### Lista Zabezpieczeń Bazy Danych

W celu ochrony integralności i poufności danych wdrożone zostaną następujące mechanizmy zabezpieczeń:

*   **System Ról i Uprawnień (RBAC - Role-Based Access Control):**
    *   Stworzenie dedykowanych ról dla różnych grup użytkowników (np. `rola_hr`, `rola_placowa`, `rola_kierownik_produkcji`, `rola_tylko_odczyt`).
    *   Nadanie minimalnych, niezbędnych uprawnień (np. dział kadr będzie miał dostęp do danych osobowych, ale nie do szczegółów zleceń produkcyjnych).
*   **Audyt i Logowanie Zmian:**
    *   **Ochrona Historii Płac:** Implementacja wyzwalacza `trg_security_payroll`, który blokuje jakąkolwiek modyfikację lub usuwanie pasków płacowych starszych niż 30 dni, zapewniając zgodność z przepisami (Compliance).
*   **Szyfrowanie Połączenia:**
    *   Wymuszenie użycia protokołu SSL/TLS dla wszystkich połączeń z bazą danych, aby chronić dane "w locie" przed podsłuchem.
*   **Polityka Silnych Haseł:**
    *   Wymuszenie stosowania złożonych haseł dla wszystkich użytkowników bazy danych.
*   **Ograniczenie Dostępu Sieciowego:**
    *   Konfiguracja firewalla na serwerze bazy danych, aby zezwalał na połączenia tylko z zaufanych adresów IP (np. z serwera aplikacji).
*   **Regularne Kopie Zapasowe:**
    *   Skonfigurowanie zautomatyzowanego procesu tworzenia i przechowywania kopii zapasowych bazy danych w celu ochrony przed utratą danych.


### Wstepny schemat, wygenerowalem go za pomoca pgAdmin 4

<img width="3200" height="3368" alt="Baza_danych_schemat" src="https://github.com/user-attachments/assets/c8d71fde-9227-4761-bc19-cd61bd7b9819" />



