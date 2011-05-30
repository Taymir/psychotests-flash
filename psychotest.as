package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.motion.MotionEvent;
	import flash.display.Shape;
	import flash.display.Graphics;
	
	
	public class psychotest extends MovieClip {
		private var drawingShape: Shape;
		private var currentColor: uint = 0x000000;
		
		public function psychotest() {
			this.initPallete();
			
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			cv_mc.addEventListener(MouseEvent.MOUSE_UP, stopDrawing);
		}
		
		public function initPallete() {
			addColorButton(0xFFFF00, 0); // Желтый
			addColorButton(0xFF0000, 1); // Красный
			addColorButton(0x9900FF, 2); // Фиолетовый
			addColorButton(0x00FF00, 3); // Зеленый
			addColorButton(0xFF9900, 4); // Оранжевый
			addColorButton(0xFFFFFF, 5); // Белый
			addColorButton(0x0000FF, 6); // Синий
			addColorButton(0x000000, 7); // Черный
			addColorButton(0x00FFFF, 8); // Голубой
			addColorButton(0xFFCCFF, 9); // Розовый
		}
		
		private function addColorButton(color: uint, num: int): MovieClip
		{
			var colorButton: MovieClip = new MovieClip();
			var g: Graphics = colorButton.graphics;
			
			g.lineStyle(1, 0x000000);
			g.beginFill(color, 1);
			g.drawRect(0, 0, 60, 20);
			g.endFill();
			
			colorButton.color = color;
			colorButton.x = 555;
			colorButton.y = 120 + 30 * num;
			colorButton.buttonMode = true;
			colorButton.addEventListener(MouseEvent.CLICK, chooseColor);
			this.addChild(colorButton);
			
			return colorButton;
		}
		
		private function chooseColor(e:MouseEvent): void
		{
			this.currentColor = e.target.color;
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			drawingShape = new Shape();
			this.addChild(drawingShape);
			cv_mc.addEventListener(MouseEvent.MOUSE_MOVE, drawing);
			
			drawingShape.graphics.lineStyle(10, this.currentColor);
			drawingShape.graphics.moveTo(mouseX, mouseY);
			
		}
		
		private function stopDrawing(e:MouseEvent): void
		{
			cv_mc.removeEventListener(MouseEvent.MOUSE_MOVE, drawing);
		}
		
		private function drawing(e:MouseEvent): void
		{
			drawingShape.graphics.lineTo(mouseX, mouseY);
		}
	}
	
}
