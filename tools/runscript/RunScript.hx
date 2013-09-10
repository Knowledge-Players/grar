import sys.FileSystem;
import sys.io.File;
import EReg;
import haxe.io.Path;
import haxe.io.Path;
import sys.FileSystem;

class RunScript{

	public static function main():Void
	{
		// haxelib run grar (0)init (1)dir (2)appName (3)widthxheight (4)fps (5)bkgColor (6)fonts (7)loader (8)cwd
		var args:Array<String> = Sys.args();
		var target: String = args[args.length-1];
		var haxelibPath: String = Sys.getCwd();
		var size: {width: Float, height: Float} = {width: 1024, height: 768};
		var fps: Int = 25;
		var bkgColor: Int = 0;
		var appName: String = "MyApp";
		var loader: String = haxelibPath+"tools/runscript/loadingCircular.swf";
		var fonts: String = "fonts";
		var structure: String = haxelibPath+"/tools/runscript/structure.xml";

		// Check args
		if(args.length < 2){
			Sys.println("Insufficient number of parameters.\nhaxelib run grar init (dir) (appName) (widthxheight) (fps) (bkgColor) (fontsDir) (loader)");
			return ;
		}
		if(args.length > 2){
			target = args[1];
		}
		if(args.length > 3){
			appName = args[2];
		}
		if(args.length > 4){
			if(args[3].indexOf("x") > -1){
				size = {width: Std.parseFloat(args[3].split("x")[0]), height: Std.parseFloat(args[3].split("x")[1])};
			}
			else
				fps = Std.parseInt(args[3]);
		}
		if(args.length > 5){
			fps = Std.parseInt(args[4]);
		}
		if(args.length > 6){
			bkgColor = Std.parseInt(args[5]);
		}
		if(args.length > 7){
			fonts = args[6];
		}
		if(args.length > 8){
			loader = FileSystem.fullPath(args[7]);
		}

		Sys.setCwd(args[args.length-1]);

		if(!FileSystem.exists(target) || !FileSystem.isDirectory(target)){
			Sys.println("The given directory \""+target+"\" is not a directory");
			return ;
		}

		var str = haxe.Resource.getString("nmml_sample");
		var t = new haxe.Template(str);
		var output = t.execute({ appName : appName, width: size.width, height: size.height, fps: fps, bkgColor: StringTools.hex(bkgColor), fonts: fonts, loader: loader});
		var nmml = File.write(appName+".nmml");
		nmml.writeString(output);
		nmml.close();

		if(args[0] == "init"){
			FileSystem.createDirectory(target+"/img");
			FileSystem.createDirectory(target+"/spritesheets");
			FileSystem.createDirectory(target+"/ui");
			FileSystem.createDirectory(target+"/xml");
			var assets = File.write("assets.xml");
			assets.writeString("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<data>\n</data>");
			assets.close();
			File.copy(structure, "structure.xml");
			Sys.command("haxelib", ["run", "nme", "build", appName+".nmml", "flash"]);

			File.copy("bin/flash/bin/"+appName+".swf", appName+".swf");
			deleteDirectoryRecursive("bin");
		}
	}

	private static function deleteDirectoryRecursive(directoryName:String):Void
	{
		for (item in FileSystem.readDirectory(directoryName)){
			var path:String = directoryName + '/' + item;

			if (FileSystem.isDirectory(path)){
				deleteDirectoryRecursive(path);
			}
			else{
				FileSystem.deleteFile(path);
			}
		}

		if (FileSystem.exists(directoryName) && FileSystem.isDirectory(directoryName)){
			FileSystem.deleteDirectory(directoryName);
		}
	}

}