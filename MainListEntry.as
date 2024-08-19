import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import flash.geom.ColorTransform;

class MainListEntry extends BasicListEntry
{
  // Stage
  
  public var name: TextField;
  public var index: TextField;
  public var modname: TextField;
  public var favorite: MovieClip;
  public var hasSuboptions: MovieClip;
	public var background: MovieClip;

  public var bg_fill: MovieClip;
  public var bg_border: MovieClip;

  // Init

  public function MainListEntry() 
  {
    super();

    bg_fill = background.fill;
    bg_border = background.border;
  }

  // Public Functions

	// @override BasicListEntry
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
    var transform = new ColorTransform();
    if (a_entryObject.color) {
      transform.rgb = a_entryObject.color;
    }
    bg_border.transform.colorTransform = transform;
    hasSuboptions._visible = a_entryObject.suboptions && a_entryObject.suboptions.length
    modname.text = a_entryObject.mod;
    index.text = a_entryObject.itemIndex;
    name.text = a_entryObject.text;
	}
}