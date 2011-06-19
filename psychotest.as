package  {
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.motion.MotionEvent;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import rl.dev.*; 
	import flash.ui.Mouse;
	
	
	public class psychotest extends MovieClip {
		const BORDER = 0;
		const INNER  = 1;
		const OUTER  = 2;
		
		const CELL_WIDTH = 180;
		const CELL_HEIGHT = 160;
		const BORDER_WIDTH = 5;
		
		private const zoomFactor: Number = 2.95;
		
		private var colors: Dictionary;
		
		private var drawingShape: Shape;
		private var currentColor: uint = 0x000000;
		
		private var bordersMask: BitmapData;
		private var innerMask: BitmapData;
		private var framesMask: BitmapData;
		
		private var figures: Array;
		
		private var console: SWFConsole;
		
		private var zoomed: Boolean = false;
		
		public function psychotest() {
			this.initPallete();
			
			this.innerMask = new figures_inner();
			this.bordersMask = new figures_borders();
			
			cv_mc.dimmer_mc.alpha = 0;
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, zoomInOut);		
			cv_mc.useHandCursor = true;
			cv_mc.buttonMode = true;
			
			brush_cursor_mc.mouseChildren = false;
			brush_cursor_mc.mouseEnabled = false;
			
			brush_cursor_mc.visible = false;
			
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
			console = new SWFConsole(640, 550, true)
			addChild( console );
		}
		
		private function zoomInOut(e:MouseEvent)
		{
			if (!zoomed)
			{
				zoomIn(e);
				zoomed = true;
			} else {
				zoomOut(e)
				zoomed = false;
			}
		}
		
		private function zoomOut(e:MouseEvent)
		{
			// Осветление фона
			new Tween(cv_mc.dimmer_mc, "alpha", Strong.easeInOut, 1.0, 0, .7, true);
			
			// Зумируем от фигуры
			new Tween(cv_mc, "scaleX2", Strong.easeInOut, zoomFactor, 1, .5, true);
			new Tween(cv_mc, "scaleY2", Strong.easeInOut, zoomFactor, 1, .5, true);
			
			// Прячем паллитру
			new Tween(panel_mc, "y", Strong.easeInOut, 535, 605, .2, true);
			
			// Убираем возможность зумаута по фону
			back_mc.removeEventListener(MouseEvent.MOUSE_UP, zoomInOut);
			back_mc.buttonMode = true;
			back_mc.useHandCursor = true;
			
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, zoomInOut);		
			cv_mc.useHandCursor = true;
			cv_mc.buttonMode = true;
			
			// Убираем возможность рисовать
			cv_mc.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			cv_mc.removeEventListener(MouseEvent.MOUSE_UP, stopDrawing);
			
			brush_cursor_mc.visible = false;
			removeEventListener(MouseEvent.MOUSE_MOVE, cursor);
		}
		
		private function zoomIn(e:MouseEvent)
		{
			// Узнаем координаты клика
			var rowcol = getFigureCords(cv_mc.mouseX, cv_mc.mouseY);
			
			// Затемнение фона
			cv_mc.dimmer_mc.dimmer_frame_mc.x = rowcol[1]  * (CELL_WIDTH + BORDER_WIDTH);
			cv_mc.dimmer_mc.dimmer_frame_mc.y = rowcol[0]  * (CELL_HEIGHT + BORDER_WIDTH);
			new Tween(cv_mc.dimmer_mc, "alpha", Strong.easeInOut, 0, 1.0, .1, true);
			
			// Зумируем к фируге
			var xzoom = rowcol[1] * (CELL_WIDTH ) / 2 + rowcol[1] * (CELL_WIDTH + BORDER_WIDTH*2);
			var yzoom = rowcol[0] * (CELL_HEIGHT ) / 2 + rowcol[0] * (CELL_HEIGHT + BORDER_WIDTH*2);
			
			cv_mc.setRegistration(xzoom, yzoom);
			
			new Tween(cv_mc, "scaleX2", Strong.easeInOut, 1, zoomFactor, .5, true);
			new Tween(cv_mc, "scaleY2", Strong.easeInOut, 1, zoomFactor, .5, true);
			
			// Выдвигаем паллитру
			new Tween(panel_mc, "y", Strong.easeInOut, 605, 535, .7, true);
			
			// Добавляем возможность зумаута по фону
			back_mc.addEventListener(MouseEvent.MOUSE_UP, zoomInOut);
			back_mc.buttonMode = true;
			back_mc.useHandCursor = true;
			
			cv_mc.removeEventListener(MouseEvent.MOUSE_DOWN, zoomInOut);		
			cv_mc.useHandCursor = false;
			cv_mc.buttonMode = false;
		}
		
		private function cursor(e:MouseEvent)
		{
			if(mask_mc.hitTestPoint(mouseX, mouseY))
			{
				Mouse.hide();
				brush_cursor_mc.visible = true
				brush_cursor_mc.x = mouseX;
				brush_cursor_mc.y = mouseY;
			} else {
				Mouse.show();
				brush_cursor_mc.visible = false;
			}
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
			//g.beginGradientFill("linear", new Array(color, color - 1), new Array(100, 100), new Array(0, 255));
			g.drawRect(0, 0, 30, 60);
			g.endFill();
			
			colorButton.color = color;
			colorButton.x = 30 + 50 * num;
			colorButton.y = 1;
			colorButton.buttonMode = true;
			colorButton.addEventListener(MouseEvent.CLICK, chooseColor);
			panel_mc.addChild(colorButton);
			
			return colorButton;
		}
		
		private function chooseColor(e:MouseEvent): void
		{
			this.currentColor = e.target.color;
			
			// Добавляем возможность рисовать
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			cv_mc.addEventListener(MouseEvent.MOUSE_UP, stopDrawing);
			
			addEventListener(MouseEvent.MOUSE_MOVE, cursor);
		}
		
		private function showResults(e:MouseEvent):void //@REFACTOR
		{
			output("==============================================");
			output("==============================================");
			
			// Выводим все фигуры, у которых закрашены границы:
			traceFigures(BORDER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТЫ ГРАНИЦЫ:");
			
			// Выводим все фигуры, у которых закрашено внутреннее пространство:
			traceFigures(INNER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТО ВНУТРЕННЕЕ ПРОСТРАНСТВО:");
			
			// Выводим все фигуры, у которых закрашено внешнее пространство:
			traceFigures(OUTER, "ФИГУРЫ,  У КОТОРЫХ ЗАТРОНУТО ВНЕШНЕЕ ПРОСТРАНСТВО:");
			
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
					if (hasKeys(this.figures[type][i][j] as Dictionary)) 
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
		
		private static function hasKeys(myDictionary:flash.utils.Dictionary):Boolean
		{
			for (var key:* in myDictionary) {
				return true;
			}
			return false;
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			drawingShape = new Shape();
			cv_mc.addChild(drawingShape);
			cv_mc.addEventListener(MouseEvent.MOUSE_MOVE, drawing);
			
			drawingShape.graphics.lineStyle(5, this.currentColor);
			drawingShape.graphics.moveTo(cv_mc.mouseX, cv_mc.mouseY);
			addPoint(this.currentColor);
		}
		
		private function stopDrawing(e:MouseEvent): void
		{
			cv_mc.removeEventListener(MouseEvent.MOUSE_MOVE, drawing);
		}
		
		private function drawing(e:MouseEvent): void
		{
			drawingShape.graphics.lineTo( cv_mc.mouseX, cv_mc.mouseY);
			addPoint(this.currentColor);
		}
		
		private function addPoint(color: uint)
		{
			var rowcol = getFigureCords(cv_mc.mouseX, cv_mc.mouseY);
			
			if (rowcol)
			{
				var maskType = getMask(cv_mc.mouseX, cv_mc.mouseY);
				
				if(color in this.figures[maskType][rowcol[0]][rowcol[1]])
					this.figures[maskType][rowcol[0]][rowcol[1]][color]++;
				else
					this.figures[maskType][rowcol[0]][rowcol[1]][color] = 1;
			}
		}
		
		private function getMask(x: int, y: int): int
		{
			x *= 2;
			y *= 2;
			
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
			var col = Math.floor(x / (CELL_WIDTH + BORDER_WIDTH)) as int;
			var row = Math.floor(y / (CELL_HEIGHT + BORDER_WIDTH)) as int;
			
			if (row >= 3)
				row = 2;
			else if (row < 0)
				row = 0;
				
			if (col >= 3)
				col = 2;
			else if (col < 0)
				col = 0;
			
			return new Array(row, col);
		}
	}
	
}
