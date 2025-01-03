# Téma Projektu

Projekt je zameraný na analýzu predaja v rámci databázy Chinook DB. Táto databáza obsahuje údaje o digitálnom predaji hudby, vrátane informácií o zákazníkoch, produktoch, skladby, albumy, žánre a fakturácii.

## 1. Úvod a popis zdrojových dát 

Cieľom projektu je analyzovať predajné údaje s cieľom identifikovať hudobné žánre, ktoré sa najviac predávajú, a zistiť, ktoré skladby a albumy sú medzi zákazníkmi najobľúbenejšie. Okrem toho projekt skúma regionálne predajné trendy, aby odhalil oblasti s najvyšším predajom.

### 1.1 Základný popis každej tabuľky

1. **Albums**  
   Táto tabuľka obsahuje informácie o albumoch, vrátane názvu albumu a identifikátora umelca. Albumy sú dôležité pre analýzu najpredávanejších albumov a pre identifikáciu úspešných umelcov, čo je kľúčové pri skúmaní predajných trendov.  
   **Stĺpce:** AlbumId, Title, ArtistId  

2. **Artists**  
   Ukladá informácie o umelcoch, ktoré sú kľúčové pre analýzu najpredávanejších umelcov a žánrov. Prepojením s albumami a skladbami môžeme identifikovať úspešných umelcov.  
   **Stĺpce:** ArtistId, Name  

3. **Customers**  
   Obsahuje údaje o zákazníkoch, ako sú meno, adresa a krajina. Tieto informácie sú kľúčové pri skúmaní regionálnych predajných trendov.  
   **Stĺpce:** CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId  

4. **Employees**  
   Obsahuje údaje o zamestnancoch, ktorí poskytujú podporu zákazníkom. Tieto údaje môžu byť relevantné pri analýze interakcií so zákazníkmi, ale nie sú priamo spojené s cieľom identifikovať najpredávanejšie produkty alebo žánre.  
   **Stĺpce:** EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, Address, City, State, Country, PostalCode, Phone, Fax, Email  

5. **Genres**  
   Ukladá informácie o hudobných žánroch. Táto tabuľka je kľúčová pre analýzu najpredávanejších žánrov a identifikáciu trendov v predaji podľa žánrov.  
   **Stĺpce:** GenreId, Name  

6. **InvoiceLines**  
   Obsahuje podrobnosti o položkách faktúr, ako sú skladby a ich ceny. Táto tabuľka je nevyhnutná pre analýzu predaja jednotlivých skladieb a určovanie ich popularity.  
   **Stĺpce:** InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity  

7. **Invoices**  
   Ukladá informácie o faktúrach, vrátane dátumu faktúry, zákazníka a celkovej sumy. Je to kľúčová tabuľka pre analýzu celkových tržieb, identifikáciu úspešných období a regionálnych predajných trendov.  
   **Stĺpce:** InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total  

8. **MediaTypes**  
   Ukladá informácie o formátoch médií, ako napríklad MP3 alebo AAC. Tieto údaje môžu byť užitočné na analýzu preferencií zákazníkov a ich vplyv na predaj podľa formátu skladby.  
   **Stĺpce:** MediaTypeId, Name  

9. **Playlists**  
   Obsahuje informácie o playlistoch, ktoré môžu obsahovať viacero skladieb. Analýza populárnych playlistov môže pomôcť identifikovať trendy v tom, aké skladby a žánre sú v rámci playlistov najobľúbenejšie.  
   **Stĺpce:** PlaylistId, Name  

10. **PlaylistTrack**  
    Táto tabuľka spája playlisty a skladby. Umožňuje analýzu obľúbenosti skladieb v rámci rôznych playlistov, čo môže naznačovať trendy v hudobných preferenciách zákazníkov.  
    **Stĺpce:** PlaylistId, TrackId  

11. **Tracks**  
    Ukladá podrobnosti o skladbách, ako sú názov, album, žáner, dĺžka skladby a cena. Táto tabuľka je kľúčová pre analýzu predajnosti jednotlivých skladieb, identifikáciu najobľúbenejších skladieb a albumov.  
    **Stĺpce:** TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice
