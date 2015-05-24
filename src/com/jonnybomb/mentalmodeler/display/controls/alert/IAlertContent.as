package com.jonnybomb.mentalmodeler.display.controls.alert
{
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;

	public interface IAlertContent
	{
		function get cancelButton():UIButton
		function get actionButton():UIButton
	}
}