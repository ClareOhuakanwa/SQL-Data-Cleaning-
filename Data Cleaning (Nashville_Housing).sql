--Data Cleaning

select *
from NashvilleHousing

--Standardize Date Formart

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

 update NashvilleHousing
 set SaleDate = convert(date, SaleDate)

 alter table NashvilleHousing
 add SaleDateConverted date;

 update NashvilleHousing
 set SaleDateConverted = convert(date, SaleDate)

 --Populate Property Address Data

select *
from NashvilleHousing
where PropertyAddress is null

select nas1.ParcelID, nas1.PropertyAddress, nas2.ParcelID, nas2.PropertyAddress, 
	isnull(nas1.PropertyAddress, nas2.PropertyAddress)
from NashvilleHousing nas1
join NashvilleHousing as nas2
	on nas1.ParcelID = nas2.ParcelID
	and nas1.[UniqueID ] <> nas2.[UniqueID ]
where nas1.PropertyAddress is null

update nas1
set PropertyAddress = isnull(nas1.PropertyAddress, nas2.PropertyAddress)
from NashvilleHousing as nas1
join NashvilleHousing as nas2
	on nas1.ParcelID = nas2.ParcelID
	and nas1.[UniqueID ] <> nas2.[UniqueID ]
where nas1.PropertyAddress is null

--Breaking Address in to individual Columns (Address, City, State)

select propertyaddress
from NashvilleHousing

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select * 
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant) as CountofSoldasVacant
from NashvilleHousing
group by SoldAsVacant
order by 2

select soldasvacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	partition by Parcelid,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					uniqueid
					) row_num

from NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


with RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	partition by Parcelid,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					uniqueid
					) row_num

from NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1

--delete unused columns

select *
from NashvilleHousing

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
drop column SaleDate