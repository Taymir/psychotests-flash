package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.motion.MotionEvent;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import rl.dev.*; 
	
	
	public class psychotest extends MovieClip {
		const BORDER = 0;
		const INNER  = 1;
		const OUTER  = 2;
		
		private var colors: Dictionary;
		
		private var drawingShape: Shape;
		private var currentColor: uint = 0x000000;
		
		private var bordersMask: BitmapData;
		private var innerMask: BitmapData;
		private var framesMask: BitmapData;
		
		private var figures: Array;
		
		private var console: SWFConsole;
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
						figures[i][j][k] = new Dictionary();
					}
				}
			}
			
			res_btn.addEventListener(MouseEvent.CLICK, showResults); 
			console = new SWFConsole( 640, 480, true)
			addChild( console );
		}
		
		public function initPallete() {
			this.colors = new Dictionary();
			colors[0xFFFF00] = "Желтый";
			colors[0xFF0000] = "Красный";
			colors[0x9900FF] = "Фиолетовый";
			colors[0x00FF00] = "Зеленый";
			colors[0xFF9900] = "Оранжевый";
			colors[0xFFFFFF] = "Белый";
			colors[0x0000FF] = "Синий";
			colors[0x000000] = "Черный";
			colors[0x00FFFF] = "Голубой";
			colors[0xFFCCFF] = "Розовый";
			
			
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
		
		private function showResults(e:MouseEvent):void //@REFACTOR
		{
			output("==============================================");
			output("==============================================");
			
			// Выводим все фигуры, у которых закрашены границы:
			traceFigures(BORDER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТЫ ГРАНИЦЫ");
			
			// Выводим все фигуры, у которых закрашено внутреннее пространство:
			traceFigures(INNER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТО ВНУТРЕННЕЕ ПРОСТРАНСТВО");
			
			// Выводим все фигуры, у которых закрашено внешнее пространство:
			traceFigures(OUTER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТО ВНЕШНЕЕ ПРОСТРАНСТВО");
			
			output("Нажмите тильду \"`\" чтобы спрятать консоль");
			console.show();
		}
		
		private function traceFigures(type: int, text: String)
		{
			output(text);
			for (var i: int = 0; i < 3; i++)
			{
				for (var j: int = 0; j < 3; j++)
				{
					if (countKeys(this.figures[type][i][j] as Dictionary) > 0) //@TODO: Можно проверять наличие хотя бы одного ключа, вместо того , чтобы считать их все
					{
						output("* Фигура " + (i+1) + "X" + (j+1) + ": ");
						for (var key:* in (this.figures[type][i][j] as Dictionary) ) {
							output("-- Цвет: " + this.colors[key] + ", точек: " + this.figures[type][i][j][key]); 
						}
					}
				}
			}
		}
		
		private static function countKeys(myDictionary:flash.utils.Dictionary):int 
		{
			var n:int = 0;
			for (var key:* in myDictionary) {
				n++;
			}
			return n;
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			drawingShape = new Shape();
			this.addChild(drawingShape);
			cv_mc.addEventListener(MouseEvent.MOUSE_MOVE, drawing);
			
			drawingShape.graphics.lineStyle(10, this.currentColor);
			drawingShape.graphics.moveTo(mouseX, mouseY);
			addPoint(this.currentColor);
		}
		
		private function stopDrawing(e:MouseEvent): void
		{
			cv_mc.removeEventListener(MouseEvent.MOUSE_MOVE, drawing);
		}
		
		private function drawing(e:MouseEvent): void
		{
			drawingShape.graphics.lineTo(mouseX, mouseY);
			addPoint(this.currentColor);
		}
		
		private function addPoint(color: uint)
		{
			var rowcol = getFigureCords(cv_mc.figures.mouseX, cv_mc.figures.mouseY);
			
			if (rowcol)
			{
				var maskType = getMask(cv_mc.figures.mouseX, cv_mc.figures.mouseY);
				
				if(color in this.figures[maskType][rowcol[0]][rowcol[1]])
					this.figures[maskType][rowcol[0]][rowcol[1]][color]++;
				else
					this.figures[maskType][rowcol[0]][rowcol[1]][color] = 1;
			}
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
			
			if (row >= 3 || row < 0 || col >= 3 || col < 0)
				return null;
			return new Array(row, col);
		}
	}
	
}
