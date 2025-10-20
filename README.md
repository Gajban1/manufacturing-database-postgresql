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
*   **Ewidencja Pracowników:** Centralna baza danych przechowująca szczegółowe informacje o pracownikach etatowych (dane osobowe, warunki zatrudnienia, historia stanowisk).
*   **Ewidencja Kontraktorów:** Osobna ewidencja dla pracowników zatrudnionych przez firmy zewnętrzne i agencje pracy tymczasowej.
*   **Rejestracja Czasu Pracy:** Moduł do zapisywania godzin pracy, nadgodzin, urlopów i absencji, stanowiący podstawę do naliczania wynagrodzeń.
*   **Zarządzanie Wynagrodzeniami:** Obsługa składników pensji (płaca zasadnicza, premie, dodatki), historia wypłat oraz generowanie list płac.

#### 2. Moduł Operacyjny i Produkcyjny
*   **Zarządzanie Zleceniami:** Śledzenie zleceń produkcyjnych od klientów, ich statusu, przypisanych zespołów oraz postępów w realizacji.
*   **Ewidencja Zasobów:** Baza do ewidencji kluczowych zasobów firmy. *(Zakres do uszczegółowienia, np. ewidencja maszyn, narzędzi, gotowych produktów).*

#### 3. Moduł Dyscypliny i BHP
*   **System Punktowy i Rejestr Wykroczeń:** System motywacyjny, w którym każdy pracownik rozpoczyna z pulą 100 punktów. Baza przechowuje zdefiniowane wykroczenia (np. błędy montażowe, spawalnicze), a ich wystąpienie powoduje odnotowanie zdarzenia i odjęcie odpowiedniej liczby punktów.
*   **Ewidencja BHP:** Monitorowanie terminów obowiązkowych szkoleń BHP, badań lekarskich oraz cyklu życia wydanej pracownikom odzieży ochronnej i narzędzi.

---

### Lista Funkcji Bazy Danych

Baza danych zostanie wyposażona w logikę (w postaci funkcji, widoków i procedur składowanych), która umożliwi realizację następujących operacji:

*   **Obliczanie wynagrodzenia:** Funkcja `oblicz_wynagrodzenie(id_pracownika, okres)` zwracająca pełne wynagrodzenie (podstawa + premia uznaniowa + premia za punkty) dla danego pracownika w zadanym okresie rozliczeniowym.
*   **Generowanie raportu kadrowego:** Widok lub funkcja generująca podsumowanie dotyczące zatrudnienia, np. liczba aktywnych pracowników, nowo zatrudnieni w danym miesiącu, wskaźnik rotacji.
*   **Raportowanie czasu pracy:** Procedura generująca miesięczny raport godzin przepracowanych, nadgodzin i absencji dla poszczególnych działów.
*   **Sprawdzanie statusu BHP:** Funkcja `sprawdz_status_bhp(id_pracownika)` zwracająca informacje o terminach najbliższych szkoleń BHP i badań lekarskich.
*   **Automatyczne przydzielanie punktów:** Wyzwalacze (Triggers), które po dodaniu nowego wpisu do bazy wykroczeń automatycznie aktualizują saldo punktowe pracownika.
*   **Wyszukiwanie pracowników:** Zoptymalizowane widoki i funkcje do szybkiego wyszukiwania pracowników według różnych kryteriów (nazwisko, dział, stanowisko).

---

### Lista Zabezpieczeń Bazy Danych

W celu ochrony integralności i poufności danych wdrożone zostaną następujące mechanizmy zabezpieczeń:

*   **System Ról i Uprawnień (RBAC - Role-Based Access Control):**
    *   Stworzenie dedykowanych ról dla różnych grup użytkowników (np. `rola_hr`, `rola_placowa`, `rola_kierownik_produkcji`, `rola_tylko_odczyt`).
    *   Nadanie minimalnych, niezbędnych uprawnień (np. dział kadr będzie miał dostęp do danych osobowych, ale nie do szczegółów zleceń produkcyjnych).
*   **Audyt i Logowanie Zmian:**
    *   Implementacja wyzwalaczy (Triggers) na kluczowych tabelach (`pracownicy`, `wynagrodzenia`), które będą zapisywać każdą zmianę (kto, co i kiedy zmienił) do osobnej tabeli audytowej.
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



