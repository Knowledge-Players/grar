package;

import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.KpGame;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
/*import mockatoo.Mock;
import mockatoo.Mockatoo;
using mockatoo.Mockatoo;*/

class KPGameTest {
    private var game: KpGame;
    private var array: Array<Part>;
    private var timer: Timer;
    private var part: Part;
    private var part2: Part;

    private var name: String;

    public function new()
    {

    }

    @BeforeClass
    public function beforeClass(): Void
    {
        game = new KpGame();
        part = new StructurePart();
        part.id = "0";
        part2 = new StructurePart();
        part2.id = "1";
        array = new Array<Part>();
        array.push(part);
        game.addPart("0", part);
        array.push(part2);
        game.addPart("1", part2);

        part.name = name = "Part1";
    }

    @Test
    public function testGetAllParts(): Void
    {
        Assert.areEqual(array.length, game.getAllParts().length);
        for(i in 0...array.length){
            Assert.areEqual(array[i], game.getAllParts()[i]);
        }

    }

    @Test
    public function testStart(): Void
    {
        Assert.areSame(part, game.start("0"));
        Assert.isNotNull(game.start("1"));
        Assert.areSame(part2, game.start("1"));
    }

    @Test
    public function testGetItemName(): Void
    {
        Assert.isNotNull(game.getItemName(part.id));
        Assert.areEqual(name, game.getItemName(part.id));
    }

    @Test
    public function testGetPart(): Void
    {
        Assert.areEqual(part2, game.getPart(part2.id));
    }

}