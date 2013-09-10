package;

import mockatoo.Mock;
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
    private var timer: Timer;
    private var part: Part;
    private var part2: Part;

    public function new()
    {

    }

    @BeforeClass
    public function beforeClass(): Void
    {
        game = new KpGame();
        part = new StructurePart();
        part2 = new StructurePart();
        array = new Array<Part>();
        array.push(part);
        game.addPart(0, part);
        array.push(part2);
        game.addPart(1, part2);
    }

    @Test
    public function testGetAllParts(): Void
    {
        Assert.areEqual(0, game.partIndex);
        Assert.areEqual(array.length, game.getAllParts().length);
        for(i in 0...array.length){
            Assert.areEqual(array[i], game.getAllParts()[i]);
        }

    }

    @Test
    public function testStart(): Void
    {
        Assert.areEqual(0, game.partIndex);
        Assert.areSame(part, game.start());
        Assert.areEqual(0, game.partIndex);
    }

    @Test
    public function testNext(): Void
    {
        Assert.isNotNull(game.next());
        Assert.areEqual(1, game.partIndex);
        Assert.isNull(game.next());
        Assert.areEqual(2, game.partIndex);
    }

}