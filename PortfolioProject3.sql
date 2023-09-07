--Cleaning Data in SQL Queries--

select *
from PortfolioProject..NashvilleHousing


-- Standardize Date Format
select saledate
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date

update PortfolioProject..NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)


-- Populate Property Address data
select *
from PortfolioProject..nashvillehousing
where propertyaddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a."UniqueID " <> b."UniqueID "
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a."UniqueID " <> b."UniqueID "
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
select propertyaddress
from PortfolioProject..nashvillehousing

select 
substring (PropertyAddress, 1, charindex (',', PropertyAddress) -1) as Address,
substring (PropertyAddress, charindex (',', PropertyAddress) + 1, len (PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar (255)

update NashvilleHousing
set PropertySplitAddress = substring (PropertyAddress, 1, charindex (',', PropertyAddress) -1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, charindex (',', PropertyAddress) + 1, len (PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename (Replace (OwnerAddress, ',', '.'), 3),
parsename (Replace (OwnerAddress, ',', '.'), 2),
parsename (Replace (OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename (Replace (OwnerAddress, ',', '.'), 3)

update NashvilleHousing
set OwnerSplitCity = parsename (Replace (OwnerAddress, ',', '.'), 2)

update NashvilleHousing
set OwnerSplitState = parsename (Replace (OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field
select Distinct (SoldAsVacant), count (SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by soldasvacant

select SoldAsVacant,
case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
end
from PortfolioProject..NashvilleHousing


-- Remove Duplicates
with CTE_RowNum as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
from PortfolioProject..NashvilleHousing
)
Select *
from CTE_RowNum
where row_num >1

--with CTE_RowNum as (
--Select *,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				 PropertyAddress,
--				 SalePrice,
--				 SaleDate,
--				 LegalReference
--				 ORDER BY
--					UniqueID
--					) as row_num
--from PortfolioProject..NashvilleHousing
--)
--Delete
--from CTE_RowNum
--where row_num >1


-- Delete Unused Columns
select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict