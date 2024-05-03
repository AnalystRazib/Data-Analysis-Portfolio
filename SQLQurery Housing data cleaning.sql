

--Step-1 Cleaning Data in SQL Queries

Select*
From PorfolioProject.dbo.HousingData





--Step-2 Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) AS NewDate
From PorfolioProject.dbo.HousingData

Update HousingData
Set SaleDate = Convert(Date, SaleDate)

--Below prompt adds a new column
Alter Table HousingData
Add SaleDateConverted date;

--Below prompt transfer the SaleDate data to the new SaleDateConverted Column
Update HousingData
Set SaleDateConverted = CONVERT(Date,SaleDate)




-- Step 3 populate missing property address data

Select *
From PorfolioProject.dbo.HousingData
--Where PropertyAddress is null
order by 2

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PorfolioProject.dbo.HousingData a
Join PorfolioProject.dbo.HousingData b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PorfolioProject.dbo.HousingData a
Join PorfolioProject.dbo.HousingData b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null

 
 
 
 -- Step 4 Breaking Addresses into Individual Comulms(Address, City, States)
 -- Dividing PropertyAddess in parts
 Select	
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) As City
From PorfolioProject.dbo.HousingData

Alter Table HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PorfolioProject.dbo.HousingData


-- Dividing OwnerAddress in parts
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PorfolioProject.dbo.HousingData

Alter Table HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From PorfolioProject.dbo.HousingData






--Step 5 Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PorfolioProject.dbo.HousingData
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	End
From PorfolioProject.dbo.HousingData

--updating SoldasVacant Column
Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	End





-- Step 6 Remove Duplicates

-- WITH fuction we created a temp table and then deleted the duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				Order by
					UniqueID
					) row_num
From PorfolioProject.dbo.HousingData
)
--Select*
DELETE 
From RowNumCTE
Where row_num >1
--order by PropertyAddress

-- in Above remove code remove(--) signs to see if the duplicates removed





-- STEP 7 Delete Unused Columns


Select *
From PorfolioProject.dbo.HousingData

ALTER TABLE PorfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject.dbo.HousingData
DROP COLUMN SaleDate