package  {
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.display.Bitmap;
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
	import flash.utils.getTimer;
	
	
	public class psychotest extends MovieClip {
		const OUTER  = 0;
		const BORDER = 1;
		const INNER  = 2;
		
		const CELL_WIDTH = 180;
		const CELL_HEIGHT = 160;
		const BORDER_WIDTH = 5;
		
		const DEFAULT_COLOR:uint = 0xEAF9D2; //@TODO: в будущем брать из флеша 
		
		private const zoomFactor: Number = 2.95;
		private var zoomed: Boolean = false;
				
		private var colors: Dictionary;
		
		private var drawingShape: Shape;
		private var currentColor: uint = 0x000000;
		
		private var bordersMask: BitmapData;
		private var innerMask: BitmapData;
		
		private var console: SWFConsole;
		
		private var fragmentAreas: Array;
		private var nativeColors:Array;
		
		public function psychotest() {
			// Инициализация паллитры
			this.initPallete();
			
			// Загрузка масок
			this.innerMask = new figures_inner();
			this.bordersMask = new figures_borders();
			this.fragmentAreas = determineFragmentAreas();
			this.nativeColors = fillNativeColors();
			
			// Инициализация canvasa: dimmer, zoominout
			cv_mc.dimmer_mc.alpha = 0;
			cv_mc.addEventListener(MouseEvent.MOUSE_DOWN, zoomInOut);		
			cv_mc.useHandCursor = true;
			cv_mc.buttonMode = true;
			
			// Настройки brush_cursor
			brush_cursor_mc.mouseChildren = false;
			brush_cursor_mc.mouseEnabled = false;
			brush_cursor_mc.visible = false;
			
			// Инициализация кнопки res и консоли
			res_btn.addEventListener(MouseEvent.CLICK, showResults); 
			console = new SWFConsole(640, 550, true)
			addChild( console );
		}
		
		private function determineFragmentAreas(): Array//@OPTIMIZE
		{
			var result = [];
			
			for (var i:int = 0; i < 3; i++)
			{
				result[i] = [];
				for (var j:int = 0; j < 3; j++)
				{
					result[i][j] = [];
					
					result[i][j][OUTER] = 0;
					result[i][j][BORDER] = 0;
					result[i][j][INNER] = 0;
					
					for (var y:int = (i) * (CELL_HEIGHT + BORDER_WIDTH); y < (i + 1) * (CELL_HEIGHT + BORDER_WIDTH); y++)
					{
						for (var x:int = (j) * (CELL_WIDTH + BORDER_WIDTH); x < (j + 1) * (CELL_WIDTH + BORDER_WIDTH); x++)
						{
							var fragment:int = getMask(x, y);
							result[i][j][fragment]++;
						}
					}
				}
			}

			return result;
		}
		
		private function fillNativeColors(): Array
		{
			var r:Array = [];
			
			r[0] = [];
			r[1] = [];
			r[2] = [];
			
			r[0][0] = [0x00FFFF, 0x0000FF, 0x9900FF];
			r[0][1] = [0xFF0000, 0xFF9900, 0xFFCCFF, 0x0000FF, 0xFFFFFF];
			r[0][2] = [0xFF0000, 0xFF9900, 0xFFCCFF, 0x0000FF, 0xFFFFFF, 0x00FF00];
			
			r[1][0] = [0x00FFFF, 0x0000FF, 0x9900FF, 0x000000, 0xFF0000, 0xFFFF00, 0x00FF00];
			r[1][1] = [0x00FFFF, 0x0000FF, 0x9900FF, 0x000000, 0xFF0000, 0xFFFF00, 0x00FF00];
			r[1][2] = [0xFFFF00, 0xFF0000, 0x00FF00, 0x9900FF, 0x000000];
			
			r[2][0] = [0xFFFF00, 0xFF0000, 0x00FF00, 0x9900FF, 0xFF9900, 0xFFCCFF, 0x000000, 0xFFFFFF];
			r[2][1] = [0xFFFF00, 0xFF0000, 0x00FF00, 0x9900FF, 0x000000];
			r[2][2] = [0xFF0000, 0xFFFF00, 0x0000FF, 0xFFFFFF];// Здесь вместо оранжевого - желтый
			
			return r;
		}
		
		public function initPallete() {
			this.colors = new Dictionary();
			//@TMP for debug output
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
			//g.beginGradientFill("linear", new Array(color, color - 1), new Array(100, 100), new Array(0, 255));//@TODO: красивые градиенты
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
			
			// Brush_cursor
			addEventListener(MouseEvent.MOUSE_MOVE, cursor);
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			drawingShape = new Shape();
			cv_mc.user_canvas_mc.addChild(drawingShape);
			cv_mc.addEventListener(MouseEvent.MOUSE_MOVE, drawing);
			
			drawingShape.graphics.lineStyle(5, this.currentColor);
			drawingShape.graphics.moveTo(cv_mc.mouseX, cv_mc.mouseY);
		}
		
		private function stopDrawing(e:MouseEvent): void
		{
			cv_mc.removeEventListener(MouseEvent.MOUSE_MOVE, drawing);
		}
		
		private function drawing(e:MouseEvent): void
		{
			drawingShape.graphics.lineTo( cv_mc.mouseX, cv_mc.mouseY);
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
			
			// Убираем brush_cursor
			brush_cursor_mc.visible = false;
			removeEventListener(MouseEvent.MOUSE_MOVE, cursor);
		}
		
		private function showResults(e:MouseEvent):void //@REFACTOR
		{
			var initTime:int = getTimer();
			
			var result:Vector.<ColorFragment> = formResultArray(cv_mc.user_canvas_mc); 
			
			output("==============================================");
			output("==============================================");
			
			for (var i = 0; i < result.length; i++)
			{
				if (i == 0 || result[i - 1].figure_row != result[i].figure_row || result[i - 1].figure_col != result[i].figure_col)
				{
					output("* Фигура " + (result[i].figure_row + 1) + "X" + (result[i].figure_col + 1) + ": ");
				}
				
				if (i == 0 || result[i - 1].fragment != result[i].fragment || result[i - 1].figure_row != result[i].figure_row || result[i - 1].figure_col != result[i].figure_col)
				{
					if(result[i].fragment == BORDER)
						output("== КОНТУР");
					else if (result[i].fragment == INNER)
						output("== ТЕЛО");
					else if (result[i].fragment == OUTER)
						output("== ФОН");
				}
				
				var color_native: String = result[i].color_native ? "Цвет родной" : "Цвет неродной";
				var figure_native: String = result[i].figure_native ? "Фигура родная" : "Фигура неродная";
				
				output("---Цвет: " + this.colors[result[i].color] + ", точек: " + result[i].size + ", " + color_native + ", " + figure_native);
			}
			output("Время обработки: " + (getTimer() - initTime));
			
			output("Нажмите тильду \"`\" чтобы спрятать консоль");
			console.show();
		}
		
		private function formResultArray(mc: MovieClip): Vector.<ColorFragment>//@OPTIMIZE
		{
			var bmp: BitmapData = new BitmapData(mc.width, mc.height, false, 0xFF00FF);
			
			var q:String = stage.quality;
			stage.quality = "low";
			bmp.draw(mc);
			stage.quality = q;
			
			var result:Vector.<ColorFragment> = new Vector.<ColorFragment>();
			
			// Для каждой строки
			for (var i:int = 0; i < 3; i++)
			{
				// Для каждого столбца -фигуры
				for (var j:int = 0; j < 3; j++)
				{
					// Для каждой фигуры:
					// Составить временный массив результатов
					var figureResult:Array = new Array();
					for (var k:int = 0; k < 3; k++)
					{
						figureResult[k] = new Dictionary();
					}
					
					var unknown: int = 0; var known: int = 0;
					// Выделить Цветовые фрагменты фигуры ixj
					for (var y:int = (i) * (CELL_HEIGHT + BORDER_WIDTH); y < (i + 1) * (CELL_HEIGHT + BORDER_WIDTH); y++)
					{
						for (var x:int = (j) * (CELL_WIDTH + BORDER_WIDTH); x < (j + 1) * (CELL_WIDTH + BORDER_WIDTH); x++)
						{
							// Для каждого пикселя
							// получить цвет пикселя
							var color:uint = bmp.getPixel(x, y);
							// получить тип фрагмента
							var fragment: int = getMask(x, y);
							
							// Проверяем цвет среди известных цветов палитры
							if (this.colors.hasOwnProperty(color))
							{
								// Добавляем +1 к количеству пикселей данного цвета в данном фрагменте
								if (figureResult[fragment].hasOwnProperty(color))
								{
									figureResult[fragment][color]++; 
								}
								else
								{
									figureResult[fragment][color] = 1;
								}
							} else if (color != 0xFF00FF) {
								//trace("Unknown color: " + color.toString(16)); //@DEBUG
							}
						}
					}
					
					// Анализируем временный массив результатов
					for (k = 0; k < 3; k++)
					{

						//@TODO: Наверное, надо отсортировать массив цветов, иначе получится непонятный разнобой
						// hint: http://www.jonnyreeves.co.uk/2009/06/sorting-values-stored-in-a-dictionary/
						for (var c:* in figureResult[k])
						{
							var CF:ColorFragment = new ColorFragment();
							CF.figure_row = i;
							CF.figure_col = j;
							CF.fragment = k;
							CF.color = c;
							CF.size = figureResult[k][c];
							
							CF.figure_native = (CF.size >= fragmentAreas[i][j][k] * 0.7 ? true : false);
							CF.color_native =  (CF.figure_native ? (nativeColors[i][j].indexOf(c) == -1 ? false : true) : true);
							
							if(CF.size >= fragmentAreas[i][j][k] * 0.007)// Игнорируем фрагменты, где закрашено менее 5% 
								result.push(CF);
						}
					}
				}
			}
			//this.addChild(new Bitmap(bmp, "auto", false));//@DEBUG
			
			return result;
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
