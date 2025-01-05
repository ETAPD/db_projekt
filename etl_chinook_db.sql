-- 1. Vytvorenie databázy a schémy
CREATE DATABASE PANDA_CHINOOK_DB;
USE DATABASE PANDA_CHINOOK_DB;
CREATE SCHEMA PANDA_CHINOOK_DB.STAGING;
USE SCHEMA PANDA_CHINOOK_DB.STAGING;
CREATE OR REPLACE STAGE my_stage;

-- 2. Vytvorenie staging tabuliek
CREATE TABLE Artist_staging (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(120) 
);

CREATE TABLE Album_staging (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(160),
    ArtistId INT,
    FOREIGN KEY (ArtistId) REFERENCES Artist_staging(ArtistId)
);

CREATE TABLE MediaType_staging (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Genre_staging (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Track_staging (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(200),
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer VARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (AlbumId) REFERENCES Album_staging(AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES MediaType_staging(MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES Genre_staging(GenreId)
);

CREATE TABLE Playlist_staging (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE PlaylistTrack_staging (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES Playlist_staging(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

CREATE TABLE Employee_staging (
    EmployeeId INT PRIMARY KEY,
    FirstName VARCHAR(20),
    LastName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    FOREIGN KEY (ReportsTo) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Customer_staging (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    Company VARCHAR(80),
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    SupportRepId INT,
    FOREIGN KEY (SupportRepId) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Invoice_staging (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10, 2),
    FOREIGN KEY (CustomerId) REFERENCES Customer_staging(CustomerId)
);

CREATE TABLE InvoiceLine_staging (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    FOREIGN KEY (InvoiceId) REFERENCES Invoice_staging(InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

-- 3. Načítanie dát do staging tabuliek
LIST @my_stage;

COPY INTO Artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO MediaType_staging
FROM @my_stage/mediatype.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Track_staging
FROM @my_stage/track.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Playlist_staging
FROM @my_stage/playlist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO PlaylistTrack_staging
FROM @my_stage/playlisttrack.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Employee_staging
FROM @my_stage/employee.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Customer_staging
FROM @my_stage/customer.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Invoice_staging
FROM @my_stage/invoice.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO InvoiceLine_staging
FROM @my_stage/invoiceline.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- 4. Vytvorenie dimenzionálnych tabuliek
CREATE TABLE Dim_Track AS
SELECT
    tr.TrackId AS Dim_TrackId,
    tr.Name,
    tr.Composer,
    tr.Milliseconds,
    tr.Bytes,
    tr.UnitPrice
FROM Track_staging tr;

CREATE TABLE Dim_Invoice AS
SELECT
    inv.InvoiceId AS Dim_InvoiceId,
    cu.firstName AS FirstName,
    cu.lastName AS LastName,
    inv.InvoiceDate,
    inv.BillingAddress,
    inv.BillingCity,
    inv.BillingState,
    inv.BillingCountry,
    inv.BillingPostalCode,
    inv.Total,
    cu.SupportRepId as SupportRepId
FROM Invoice_staging inv
JOIN Customer_staging cu ON inv.CustomerId = cu.CustomerId;

CREATE TABLE Dim_Date AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY CAST(i.invoicedate AS DATE)) AS Dim_DateId,
    CAST(i.invoicedate AS DATE) AS date,
    DATE_PART('day', i.invoicedate) AS day,
    DATE_PART('month', i.invoicedate) AS month,
    DATE_PART('year', i.invoicedate) AS year,
    DATE_PART('quarter', i.invoicedate) AS quarter,
    CASE
        WHEN DATE_PART('dow', i.invoicedate) = 0 THEN 'Sunday'
        WHEN DATE_PART('dow', i.invoicedate) = 1 THEN 'Monday'
        WHEN DATE_PART('dow', i.invoicedate) = 2 THEN 'Tuesday'
        WHEN DATE_PART('dow', i.invoicedate) = 3 THEN 'Wednesday'
        WHEN DATE_PART('dow', i.invoicedate) = 4 THEN 'Thursday'
        WHEN DATE_PART('dow', i.invoicedate) = 5 THEN 'Friday'
        WHEN DATE_PART('dow', i.invoicedate) = 6 THEN 'Saturday'
    END AS day_name,
    DATE_PART('dow', i.invoicedate) + 1 AS day_week,
    EXTRACT(WEEK FROM DATE_TRUNC('WEEK', i.invoicedate + INTERVAL '1 DAY')) AS week,
    CASE
        WHEN DATE_PART('month', i.invoicedate) = 1 THEN 'January'
        WHEN DATE_PART('month', i.invoicedate) = 2 THEN 'February'
        WHEN DATE_PART('month', i.invoicedate) = 3 THEN 'March'
        WHEN DATE_PART('month', i.invoicedate) = 4 THEN 'April'
        WHEN DATE_PART('month', i.invoicedate) = 5 THEN 'May'
        WHEN DATE_PART('month', i.invoicedate) = 6 THEN 'June'
        WHEN DATE_PART('month', i.invoicedate) = 7 THEN 'July'
        WHEN DATE_PART('month', i.invoicedate) = 8 THEN 'August'
        WHEN DATE_PART('month', i.invoicedate) = 9 THEN 'September'
        WHEN DATE_PART('month', i.invoicedate) = 10 THEN 'October'
        WHEN DATE_PART('month', i.invoicedate) = 11 THEN 'November'
        WHEN DATE_PART('month', i.invoicedate) = 12 THEN 'December'
    END AS month_name
FROM invoice_staging i;

CREATE TABLE Dim_Employee AS
SELECT
    em.EmployeeId AS Dim_EmployeeId,
    em.FirstName,
    em.LastName,
    em.Title,
    em.ReportsTo,
    em.BirthDate,
    em.HireDate,
    em.Address,
    em.City,
    em.State,
    em.Country,
    em.PostalCode,
    em.Phone,
    em.Fax,
    em.Email
FROM Employee_staging em;

CREATE TABLE Dim_Genre AS
SELECT
    ge.GenreId AS Dim_GenreId,
    ge.Name 
FROM Genre_staging ge;

CREATE TABLE Dim_Playlist AS
SELECT
    pl.PlaylistId AS Dim_PlaylistId,
    pl.Name 
FROM Playlist_staging pl;

CREATE TABLE Dim_Artist AS
SELECT
    ar.ArtistId AS Dim_ArtistId,
    ar.Name
FROM Artist_staging ar;

-- 5. Vytvorenie faktovej tabuľky
CREATE TABLE Fact_Sales AS
SELECT
    il.InvoiceLineId AS Fact_SalesId,
    il.UnitPrice AS UnitPrice,
    il.Quantity AS Quantity,
    di.Dim_InvoiceId AS InvoiceId,
    dt.Dim_TrackId AS TrackId,
    dd.Dim_DateId AS DateId,
    de.Dim_EmployeeId AS EmployeeId,
    dg.Dim_GenreId AS GenreId,
    dp.Dim_PlaylistId AS PlaylistId
FROM InvoiceLine_staging il
JOIN Dim_Track dt ON il.TrackId = dt.Dim_TrackId
JOIN Dim_Invoice di ON il.InvoiceId = di.Dim_InvoiceId
JOIN Dim_Date dd ON CAST(di.InvoiceDate AS DATE) = dd.Date
JOIN Dim_Employee de ON di.SupportRepId = de.Dim_EmployeeId
LEFT JOIN Track_staging tr ON il.TrackId = tr.TrackId
LEFT JOIN PlaylistTrack_staging pt ON il.TrackId = pt.TrackId
LEFT JOIN Dim_Genre dg ON tr.GenreId = dg.Dim_GenreId
LEFT JOIN Dim_Playlist dp ON pt.PlaylistId = dp.Dim_PlaylistId
LEFT JOIN Album_staging al ON tr.AlbumId = al.AlbumId
LEFT JOIN Artist_staging ar ON al.ArtistId = ar.ArtistId
LEFT JOIN Dim_Artist da ON ar.ArtistId = da.Dim_ArtistId;





-- 6. Odstránenie staging tabuliek
DROP TABLE Artist_staging;
DROP TABLE Album_staging;
DROP TABLE MediaType_staging;
DROP TABLE Genre_staging;
DROP TABLE Track_staging;
DROP TABLE Playlist_staging;
DROP TABLE PlaylistTrack_staging;
DROP TABLE Employee_staging;
DROP TABLE Customer_staging;
DROP TABLE Invoice_staging;
DROP TABLE InvoiceLine_staging;



