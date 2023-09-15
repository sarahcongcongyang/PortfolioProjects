/*

cleaning data in sql

*/

SELECT *
FROM PortfolioProject..NashvilleHousing


---------standarise data format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)
--didn't work

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


-----------populate property address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


----------breaking out address into individual columns(Address, City, State)
--PropertyAddress
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PAddress nvarchar(255);

UPDATE NashvilleHousing
SET PAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PCity nvarchar(255);

UPDATE NashvilleHousing
SET PCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

---Ownner address
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OAddress nvarchar(255);

UPDATE NashvilleHousing
SET OAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OCity nvarchar(255);

UPDATE NashvilleHousing
SET OCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OState nvarchar(255);

UPDATE NashvilleHousing
SET OState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--SELECT *
--FROM PortfolioProject..NashvilleHousing


-----------change Y and N to Yes and No in "sold as vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N'  THEN 'No'
	 WHEN SoldAsVacant = 'Y'  THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant = 'N'  THEN 'No'
	 WHEN SoldAsVacant = 'Y'  THEN 'Yes'
	 ELSE SoldAsVacant
	 END


------------remove duplicates
WITH RowNumberCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID) AS RowNumber
FROM PortfolioProject..NashvilleHousing
)
SELECT *--DELETE--
FROM RowNumberCTE
WHERE RowNumber > 1


---------------remove unused columns
--not common
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate