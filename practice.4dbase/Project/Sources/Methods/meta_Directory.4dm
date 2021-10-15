//%attributes = {"invisible":true}
C_OBJECT:C1216($1; $2; $0)

/*

プロパティリストのメタ情報式

meta_Directory(Form.Directory.meta.selected; Form.Directory.meta.unselected)

*/

$selected:=$1
$unselected:=$2

$event:=FORM Event:C1606

If ($event.isRowSelected)
	$0:=$selected
Else 
	$0:=$unselected
End if 