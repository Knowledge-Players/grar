package ;

import utest.TestResult;
import utest.Runner;
import utest.ui.Report;

class RunTest {

	private static var nbOK:Int = 0;

	public static function main() {
		var runner = new Runner();
		runner.onProgress.add(function(r: { result : TestResult, done : Int, totals : Int }){
			if(r.result.allOk())
				nbOK++;
		});

		CompileTime.importPackage("grar");


		for ( cls in CompileTime.getAllClasses("grar") ) {
			if(StringTools.endsWith(Type.getClassName(cls), "Test"))
				runner.addCase(Type.createInstance( cls, [] ));
		}
		var report = Report.create(runner);

		runner.run();

		#if sys
		Sys.exit(nbOK == runner.length ? 0 : 1);
		#end
	}
}