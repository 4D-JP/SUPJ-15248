If (Form event code:C388=On Clicked:K2:4)
	
	$status:=Form:C1466.Directory.item.save(dk auto merge:K85:24)
	
	If (Not:C34($status.success))
		
		Form:C1466.info:=$status
		
		Form:C1466.Directory.item.reload()
		
	Else 
		
		Form:C1466.displaySelection()
		
	End if 
	
End if 