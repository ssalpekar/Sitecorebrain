#Set the Parent folder
$RootItem = Show-Input "Set the root item path - ex : /sitecore/content" 

#Set the template of the content item to filter out the item which you need to update. 
$templateName = Show-Input "Enter the template name, ex : Sample Item"

#To get only the items based on the said $templateName
$selectedItems = Get-ChildItem -Path $RootItem -Recurse | Where-Object { $_.TemplateName -eq $templateName} -ErrorAction SilentlyContinue 
if(!$selectedItems)
{
	Write-Host "Item is not available under the entered root path or template name!"
	break
}

#Set the rendering id whose datasource is needed
$renderingID = Show-Input "Enter the rendering ID, ex :{DCEE78E1-1843-4456-A13A-F10A12191630}"

#Set the place holder of the rendering
$placeHolder = Show-Input "Enter the placeholder key, ex : main" 

#Set the device
$deviceLayout = Get-LayoutDevice “Default” 

#Set the rendering which we need to add
$renderingPath = Show-Input "Enter the rendering path, ex : /sitecore/layout/Renderings/Feature/Experience Accelerator/Page Content/RichText" 

#Getting the rendering as a renderingDefinition item
$renderingItem = Get-Item -Database “master” -Path $renderingPath | New-Rendering -Placeholder $placeHolder 
if(!$renderingItem)
{
	Write-Host "Etered rendering path is not valid!"
	break
}

#Set the language 
$Language = Show-Input "Enter the language version, ex : en"

#Removed the rendering from Shared Layout
$RenderingRemovalConfirmation = Show-Confirm -Title "Do you want to remove the rendering from Shared Layout?"

#Add the rendering from Final Layout
$RenderingAdditionConfirmation = Show-Confirm -Title "Do you want to add the rendering from Final Layout?"

#Copy the datasource confirmation from Shared Layout
$RenderingRemovalConfirmation = Show-Confirm -Title "Do you want to set the same datasource item in rendering of Final Layout?"


if($selectedItems)
{
	foreach($item in $selectedItems)
	{
		#get renderings from the item’s shared layout
		$renderings = Get-Rendering -Item $item -Device $deviceLayout -Placeholder $placeHolder 
		$renderings
		if($renderings)
		{
			foreach($rendering in $renderings)
			{
				if($rendering.ItemID -eq $renderingID)
				{
					if($rendering.DataSource)
					{
						#Get the selected rendering datasource. 
						$dataSourceItem = Get-Item $rendering.DataSource
				
						$item.Editing.BeginEdit();
				
						if($RenderingRemovalConfirmation -eq 'yes')
						{
							#Remove the rendering from the Shared Layout
							Remove-Rendering -Item $item -Instance $rendering -Device $deviceLayout 
						}	
						if($RenderingAdditionConfirmation -eq 'yes')
						{
							#Add the rendering in Final Layout
							Add-Rendering -Item $item -Language $Language -PlaceHolder $placeHolder -Instance $renderingItem -Device $deviceLayout -Datasource $dataSourceItem.Paths.FullPath -FinalLayout
						}
					
						$item.Editing.EndEdit();
					}
					else
					{
						$item.Editing.BeginEdit();
				
						if($RenderingRemovalConfirmation -eq 'yes')
						{
							#Remove the rendering from the Shared Layout
							Remove-Rendering -Item $item -Instance $rendering -Device $deviceLayout 
						}	
						if($RenderingAdditionConfirmation -eq 'yes')
						{
							#Add the rendering in Final Layout
							Add-Rendering -Item $item -Language $Language -PlaceHolder $placeHolder -Instance $renderingItem -Device $deviceLayout -FinalLayout
						}
						
						$item.Editing.EndEdit();
					}
				}
				else
				{
					Write-Host "Selected rednering is not present!"
				}
			}
		}
		else
		{
			Write-Host "Entered rendering is not available in the items!"
		}
	}
}
else
{
	Write-Host "Item is not available under the entered root path or template name!"
}
