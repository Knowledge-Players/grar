package;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.KpGame;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.Mockatoo;
using mockatoo.Mockatoo;

class KPGameTest {
    private var game: KpGame;
    private var array: Array<Part>;

    public function new()
    {

    }

    @BeforeClass
    public function beforeClass(): Void
    {
        game = KpGame.mock();
        var part = new StructurePart();
        array = new Array<Part>();
        array.push(part);
        //game.addPart(0, part);
        game.getAllParts().returns(array);
    }

    @Test
    public function testExample(): Void
    {
        Assert.areEqual(array.length, game.getAllParts().length);
        for(i in 0...array.length){
            Assert.areEqual(array[i], game.getAllParts()[i]);
        }

    }

}