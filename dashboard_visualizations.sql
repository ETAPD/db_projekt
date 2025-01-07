-- Graf 1: Najpredávanejšie žánre (top 10 žánrov)
SELECT
    dg.Name AS Genre,
    SUM(fs.UnitPrice * fs.Quantity) AS TotalSales
FROM Fact_Sales fs
JOIN Dim_Genre dg ON fs.GenreId = dg.Dim_GenreId
GROUP BY dg.Name
ORDER BY TotalSales DESC
LIMIT 10;

-- Graf 2: Najpopulárnejšie playlisty (top 10 playlistov)
SELECT
    dp.Name AS Playlist,
    COUNT(fs.PlaylistId) AS PlaylistCount
FROM Fact_Sales fs
JOIN Dim_Playlist dp ON fs.PlaylistId = dp.Dim_PlaylistId
GROUP BY dp.Name
ORDER BY PlaylistCount DESC
LIMIT 10;

-- Graf 3: Predaje podľa krajín
SELECT
    di.BillingCountry AS Country,
    SUM(fs.UnitPrice * fs.Quantity) AS TotalSales
FROM Fact_Sales fs
JOIN Dim_Invoice di ON fs.InvoiceId = di.Dim_InvoiceId
GROUP BY di.BillingCountry
ORDER BY TotalSales DESC;

-- Graf 4: Najpredávanejšie skladby podľa rokov
SELECT
    Year,
    Track,
    TotalSales
FROM (
    SELECT
        dt.Name AS Track,
        dd.year AS Year,
        SUM(fs.UnitPrice * fs.Quantity) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY dd.year ORDER BY SUM(fs.UnitPrice * fs.Quantity) DESC) AS rn
    FROM Fact_Sales fs
    JOIN Dim_Track dt ON fs.TrackId = dt.Dim_TrackId
    JOIN Dim_Date dd ON fs.DateId = dd.Dim_DateId
    GROUP BY dt.Name, dd.year
) ranked_tracks
WHERE rn = 1
ORDER BY Year, TotalSales DESC;

-- Graf 5: Najpredávanejší umelci (top 10 umelcov)
SELECT
    da.Name AS Artist,
    SUM(fs.Quantity) AS Quantity
FROM Fact_Sales fs
JOIN Dim_Artist da ON fs.ArtistId = da.Dim_ArtistId
GROUP BY da.Name
ORDER BY Quantity DESC
LIMIT 10;