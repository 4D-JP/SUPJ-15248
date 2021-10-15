If (Form event code:C388=On Clicked:K2:4)
	
	$status:=Form:C1466.Directory.newItem.save(dk auto merge:K85:24)
	
	If (Not:C34($status.success))
		
		Form:C1466.info:=$status
		
	Else 
		
		Form:C1466.Directory.col:=Form:C1466.Directory.col.or(Form:C1466.Directory.newItem)
		
		Form:C1466.Directory.all:=ds:C1482.Directory.all(Form:C1466.Directory.context).orderBy("ID asc")
		
		Form:C1466.displaySelection()
		
	End if 
	
End if 