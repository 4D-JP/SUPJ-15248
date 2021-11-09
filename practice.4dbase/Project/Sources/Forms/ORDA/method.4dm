$event:=FORM Event:C1606

Case of 
	: ($event.code=On After Edit:K2:43)
		
/*
		
検索文字列がクリアされた場合は全件を表示する
		
*/
		
		If ($event.objectName="inp")
			$imp:=Get edited text:C655
			If (Match regex:C1019("\\s*"; $imp))
				Form:C1466.Directory.col:=Form:C1466.Directory.all
			End if 
		End if 
		
	: ($event.code=On Load:K2:1)
		
		Form:C1466.Or_opt:=1
		Form:C1466.And_opt:=0
		
		Form:C1466.inp:=""
		
		$queryOptions:=New object:C1471("context"; "lb.Directory")
		
		Form:C1466.Directory:=New object:C1471("col"; Null:C1517; "all"; Null:C1517; "item"; Null:C1517; "pos"; Null:C1517; "sel"; Null:C1517; "context"; $queryOptions)
		
		Form:C1466.Directory.all:=ds:C1482.Directory.all(Form:C1466.Directory.context).orderBy("ID asc")
		Form:C1466.Directory.col:=Form:C1466.Directory.all
		
/*
		
プロパティリストのメタ情報式
		
meta_Directory(Form.Directory.meta.selected; Form.Directory.meta.unselected)
		
セレクションハイライトを非表示: True
		
*/
		
		Form:C1466.Directory.meta:=New object:C1471("selected"; New object:C1471; "unselected"; New object:C1471)
		Form:C1466.Directory.meta.unselected.fill:=-1
		Form:C1466.Directory.meta.unselected.stroke:="automatic"
		Form:C1466.Directory.meta.selected.fill:="#FFE0E0"
		Form:C1466.Directory.meta.selected.stroke:="#FF1010"
		
		$Directory:=ds:C1482.Directory
		
		Form:C1466.Directory.fields:=New collection:C1472
		For each ($attribute; $Directory)
			If ($Directory[$attribute].kind="storage")
				$field:=$Directory[$attribute]
				$field.name:=$attribute
				Form:C1466.Directory.fields.push($field)
			End if 
		End for each 
		
		Form:C1466.addRecord:=Formula:C1597(FORM GOTO PAGE:C247(3))
		Form:C1466.modifyRecord:=Formula:C1597(FORM GOTO PAGE:C247(2))
		Form:C1466.displaySelection:=Formula:C1597(FORM GOTO PAGE:C247(1))
		
		OBJECT SET FILTER:C235(*; "Dob#@"; "&\"0-9;.;-;/\"")  //日付はIMEをオフにする
		
		OBJECT SET PLACEHOLDER:C1295(*; "inp"; "FN LN PNで検索…")
		
		GOTO OBJECT:C206(*; "inp")
		
	: ($event.code=On Page Change:K2:54)
		
		Form:C1466.info:=""
		
		OBJECT SET ENABLED:C1123(*; "Save#@"; False:C215)
		
		If (FORM Get current page:C276=3)
			Form:C1466.Directory.newItem:=ds:C1482.Directory.new()
		End if 
		
	: (($event.code=On Clicked:K2:4) & (($event.objectName="And") | ($event.objectName="Or")))\
		 | (($event.code=On Data Change:K2:15) & ($event.objectName="inp"))
		
/*
		
検索
		
*/
		
		If ($event.objectName="inp")
			$imp:=Get edited text:C655
			GOTO OBJECT:C206(*; $event.objectName)  //フォーカスを移動しない
		Else 
			$imp:=Form:C1466.inp
		End if 
		
		If (Not:C34(Match regex:C1019("\\s*"; $imp)))
			
			$phrases:=Split string:C1554($imp; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).map("map_wildcard")
			
			$queryParams:=New object:C1471
			$queryParams.attributes:=New object:C1471
			$queryParams.parameters:=New object:C1471
			$queryParams.attributes.姓:="FN"
			$queryParams.attributes.名:="LN"
			$queryParams.attributes.生年月日:="Dob"
			$queryParams.attributes.電話番号:="PN"
			$queryParams.parameters.検索文字列:=$phrases
			
			$queryCriteria:=New collection:C1472(":姓 IN :検索文字列"; ":名 IN :検索文字列"; ":電話番号 IN :検索文字列")
			
/*
			
日付検索の例
			
*/
			
			ARRAY LONGINT:C221($pos; 0)
			ARRAY LONGINT:C221($len; 0)
			
			$queryParams.args:=New object:C1471
			$i:=0
			
			For each ($value; Split string:C1554($imp; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2))
				Case of 
					: (Match regex:C1019("(\\d{2,4}\\D)?(\\d{1,2})\\D(\\d{1,2})"; $value; 1; $pos; $len))
						
						$m:=Num:C11(Substring:C12($value; $pos{2}; $len{2}))
						$d:=Num:C11(Substring:C12($value; $pos{3}; $len{3}))
						$i:=$i+1
						$日付:="日付"+String:C10($i)  //値に名前をつける
						
						$year:=Substring:C12($value; $pos{1}; $len{1})
						
						Case of 
							: (Length:C16($year)=0)
								$y:=0  //年指定なし
							: (Length:C16($year)=4)
								$y:=Num:C11($year)
							Else 
								$y:=Num:C11($year)+2000
						End case 
						
						If ($y=0)
							//月日だけで検索する場合
							$queryParams.args[$日付]:=Add to date:C393(!00-00-00!; 2000; $m; $d)
							$queryCriteria.push("eval((Month of(This.Dob)=Month of($1."+$日付+")) & (Day of(This.Dob)=Day of($1."+$日付+")))")
						Else 
							//年月日で検索する場合
							$queryParams.parameters[$日付]:=Add to date:C393(!00-00-00!; $y; $m; $d)
							$queryCriteria.push(":生年月日 == :"+$日付)
						End if 
						
				End case 
				
			End for each 
			
			Case of 
				: (Form:C1466.Or_opt=1)
					Form:C1466.Directory.col:=Form:C1466.Directory.all.query($queryCriteria.join(" or "); $queryParams)
				: (Form:C1466.And_opt=1)
					Form:C1466.Directory.col:=Form:C1466.Directory.all.query($queryCriteria.join(" and "); $queryParams)
			End case 
			
		End if 
		
	: ($event.code=On Data Change:K2:15)
		
		$page:=FORM Get current page:C276
		
		Case of 
			: ($page=2) | ($page=3)
				
				C_OBJECT:C1216($item)
				
				Case of 
					: ($page=2)
						$item:=Form:C1466.Directory.item
					: ($page=3)
						$item:=Form:C1466.Directory.newItem
				End case 
				
				C_COLLECTION:C1488($touchedAttributes; $blankAttributes)
				
				$blankAttributes:=New collection:C1472
				
				For each ($field; Form:C1466.Directory.fields)
					
					Case of 
						: ($field.type="number")
							If ($item[$field.name]=0)
								$blankAttributes.push($field.name)
							End if 
						: ($field.type="string")
							If ($item[$field.name]="")
								$blankAttributes.push($field.name)
							End if 
						: ($field.type="date")
							If ($item[$field.name]=!00-00-00!)
								$blankAttributes.push($field.name)
							End if 
					End case 
				End for each 
				
				$touchedAttributes:=$item.touchedAttributes()
				
				Form:C1466.info:=New collection:C1472(\
					"touchedAttributes"; ":"; $touchedAttributes; "\r"; \
					"blankAttributes"; ":"; $blankAttributes).join()
				
/*
				
空のフィールドが0
				
かつ
				
フィールドの値が変更された
				
»Saveボタンを有効化する
				
*/
				
				OBJECT SET ENABLED:C1123(*; "Save#@"; ($blankAttributes.length=0) & ($touchedAttributes.length#0))
				
		End case 
		
	: ($event.code=On Clicked:K2:4)
		
		C_OBJECT:C1216($item)
		
		$item:=Form:C1466.Directory.item
		
		If ($item#Null:C1517)
			
			$idx:=$item.indexOf(Form:C1466.Directory.col)
			
			Case of 
				: ($event.objectName="First")
					
					Form:C1466.Directory.item:=Form:C1466.Directory.item.first()
					
				: ($event.objectName="Previous")
					
					Form:C1466.Directory.item:=Form:C1466.Directory.item.previous()
					
				: ($event.objectName="Next")
					
					Form:C1466.Directory.item:=Form:C1466.Directory.item.next()
					
				: ($event.objectName="Last")
					
					Form:C1466.Directory.item:=Form:C1466.Directory.item.last()
					
				: ($event.objectName="Delete")
					
					$status:=Form:C1466.Directory.item.drop()
					
					If (Not:C34($status.success))
						
						Form:C1466.info:=$status
						
						Form:C1466.Directory.item.reload()
						
					Else 
						
						Form:C1466.Directory.col:=Form:C1466.Directory.col.minus(Form:C1466.Directory.item)
						
						Form:C1466.Directory.all:=ds:C1482.Directory.all(Form:C1466.Directory.context).orderBy("ID asc")
						
						Form:C1466.displaySelection()
						
					End if 
					
			End case 
			
			$idx:=Form:C1466.Directory.item.indexOf(Form:C1466.Directory.col)
			
			OBJECT SET ENABLED:C1123(*; "First"; ($idx>0))
			OBJECT SET ENABLED:C1123(*; "Previous"; ($idx>0))
			OBJECT SET ENABLED:C1123(*; "Next"; ($idx<(Form:C1466.Directory.col.length-1)))
			OBJECT SET ENABLED:C1123(*; "Last"; ($idx<(Form:C1466.Directory.col.length-1)))
			
			Form:C1466.info:=""
			
			OBJECT SET ENABLED:C1123(*; "Save#@"; False:C215)
			
		End if 
		
End case 
