/*

Cleaning Data in SQL Queries

*/


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID= b.ParcelID  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Using [SUBSTRING,CHARINDEX,LEN,PARSENAME,REPLACE]

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add AddressSplited nvarchar(255);

Update NashvilleHousing
SET AddressSplited = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add CitySplited nvarchar(255);

Update NashvilleHousing
SET CitySplited = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



select PARSENAME(replace(OwnerAddress,',','.'),1),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),3)
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add OwnerAddressSplited nvarchar(255);

ALTER TABLE NashvilleHousing
Add  OwnerCitySplited nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerStateSplited nvarchar(255);

Update NashvilleHousing
SET  OwnerAddressSplited =PARSENAME(replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
SET OwnerCitySplited = PARSENAME(replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
SET OwnerStateSplited = PARSENAME(replace(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
  End
From PortfolioProject.dbo.NashvilleHousing 


Update NashvilleHousing
SET  SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
  End

  Select Distinct(SoldAsVacant)
  From PortfolioProject.dbo.NashvilleHousing 

  

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
select *, 
ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
  From PortfolioProject.dbo.NashvilleHousing 
  )

  Delete 
  from RowNumCTE
  WHERE row_num>1

  Select * 
  from RowNumCTE
  WHERE row_num>1

  
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

