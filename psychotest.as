package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.motion.MotionEvent;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.BitmapData;
	
	
	public class psychotest extends MovieClip {
		const BORDER = 0;
		const INNER  = 1;
		const OUTER  = 2;
		
		private var drawingShape: Shape;
		private var currentColor: uint = 0x000000;
		
		private var bordersMask: BitmapData;
		private var innerMask: BitmapData;
		private var framesMask: BitmapData;
		
		private var figures: Array;
		
		public function psychotest() {
			this.initPallete();
			
			this.framesMask = new figures_masks_frames();
			this.innerMask = new figures_masks_inner();
			this.bordersMask = new figures_masks_borders();
			
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			cv_mc.addEventListener(MouseEvent.MOUSE_UP, stopDrawing);
			
			figures = [];
			for(var i:int = 0; i < 3; i++)
			{
				figures[i] = [];
				for(var j:int = 0; j < 3; j++)
				{
					figures[i][j] = [];
					for(var k:int = 0; k < 3; k++)
					{
						figures[i][j][k] = 0;
					}
				}
			}
			
			res_btn.addEventListener(MouseEvent.CLICK, showResults); 
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
		
		private function showResults(e:MouseEvent):void
		{
			trace(this.figures);
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			drawingShape = new Shape();
			this.addChild(drawingShape);
			cv_mc.addEventListener(MouseEvent.MOUSE_MOVE, drawing);
			
			drawingShape.graphics.lineStyle(10, this.currentColor);
			drawingShape.graphics.moveTo(mouseX, mouseY);
			addPoint();
		}
		
		private function stopDrawing(e:MouseEvent): void
		{
			cv_mc.removeEventListener(MouseEvent.MOUSE_MOVE, drawing);
		}
		
		private function drawing(e:MouseEvent): void
		{
			drawingShape.graphics.lineTo(mouseX, mouseY);
			addPoint();
		}
		
		private function addPoint()
		{
			var rowcol = getFigureCords(cv_mc.figures.mouseX, cv_mc.figures.mouseY);
			var maskType = getMask(cv_mc.figures.mouseX, cv_mc.figures.mouseY);
			
			this.figures[rowcol[0]][rowcol[1]][maskType]++;
		}
		
		private function getMask(x: int, y: int): int
		{
			var border: Number = this.bordersMask.getPixel(x, y) / 0xFFFFFF;
			var inner: Number = this.innerMask.getPixel(x, y) / 0xFFFFFF;

			if(border < .5)
			{
				return BORDER;
			}
			else if(inner < .5)
			{
				return INNER;
			}
			else
			{
				return OUTER;
			}
		}
		
		private function getFigureCords(x: int, y: int)
		{
			var color = this.framesMask.getPixel(x, y);
			var g = color >> 8 &0xFF;
			var b = color & 0xFF;
			
			var row = Math.floor(g / 0x33 - 1) as int;
			var col = Math.floor(b / 0x33 - 1) as int;
			
			return new Array(row, col);
		}
	}
	
}
