package ;

import utest.Runner;
import utest.ui.Report;

class RunTest {

	private static var nbOK:Int = 0;

	public static function main() {
		var runner = new Runner();

		CompileTime.importPackage("grar.parser");


		for ( cls in CompileTime.getAllClasses("grar.parser") ) {
			runner.addCase(Type.createInstance( cls, [] ));
		}
		var report = Report.create(runner);

		runner.run();
	}
}