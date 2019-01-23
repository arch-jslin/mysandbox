class Test1 extends hxd.App {

    var R    : Float;
    var FSIZE: Int = 80;

    var bmp : h2d.Bitmap;
    var globe:h2d.Bitmap;
    var rv_ : Float = 0;
    var ra_ : Float = 0;
    var names_ : Array<String> = ["B", "D", "E", "G", "H", "I", "J", "K", "L", "M"];
    //var names_ : Array<String> = ["1", "2", "3", "4", "5", "6"];
    var texts_ : Array<h2d.Text> = new Array<h2d.Text>();
    var flag_  : Bool = false;
    var index_last_ : Int = 0;
    var index_next_ : Int = 0;
    
    var beep_ : hxd.res.Sound;
    
    override function init() {

        R = 400;

        //var tile = h2d.Tile.fromColor(0xFF0000, 50, 375);
        var tile = hxd.Res.logo.toTile();
        tile = tile.center(); //why? why not tile.center(); what's the assignment for?
        globe = new h2d.Bitmap(tile, s2d);
        globe.x = s2d.width * 0.5;
        globe.y = s2d.height * 0.5;
        globe.scale(0.6);
        
        //re-use tile
        tile = hxd.Res.pin.toTile();
        tile = tile.center();
        bmp = new h2d.Bitmap(tile, s2d);
        bmp.x = s2d.width * 0.5;
        bmp.y = s2d.height * 0.5;
        bmp.scale(0.6);
/*         bmp.tile.dx = -25;
        bmp.tile.dy = -375;  */
        
        beep_ = hxd.Res.Blip_Select3;
        
        populate_texts();
    }
    
    override function update(dt:Float) {
        rv_ += ra_;
        if( rv_ > 0.25 )    rv_ = 0.25;
        else if( rv_ < 0 ) rv_ = 0;
        
        bmp.rotation += rv_ * dt;
        
        if( hxd.Key.isPressed( hxd.Key.MOUSE_LEFT ) ) {
            if( flag_ == false ) { 
              flag_ = true;
              ra_ = 0.004;
            }
            else {
              flag_ = false;
              ra_ = -0.0006;
            }
        }
        
        var i = 0;
        for( t in texts_ ) {
            if( is_pin_in_the_slice_of(i) ) {
                t.textColor = 0xFF0000;
                t.parent.scaleX = 2;
                t.parent.scaleY = 2;
                t.dropShadow = { dx : 5, dy : 5, color : 0xFFFFFF, alpha : 1 }; // This is super-duper stupid performance wise.
                index_next_ = i;                
            }
            else {
                t.textColor = 0xFFFFFF;
                t.parent.scaleX = 1;
                t.parent.scaleY = 1;
                t.dropShadow = null;
            }
            i += 1;
        }
        
        //Beep
        if( index_last_ != index_next_ ) {
            beep_.play();
            index_last_ = index_next_;
        }
    }
    
    function is_pin_in_the_slice_of(n) {
        var text_center_offset_degree = (360 / names_.length) / 2;
        var from_degree = ((360 / names_.length) *  n);
        var to_degree   = ((360 / names_.length) * (n+1));
        var clamped_degree = (bmp.rotation * 180 / Math.PI + text_center_offset_degree) % 360;
        if( clamped_degree >= from_degree && clamped_degree < to_degree ) 
           return true;
        return false;
    }
    
    function populate_texts() {
    
        var font = hxd.Res.trueTypeFont.build(FSIZE);
        var i = 0;
        for( s in names_ ) {
            var tempContainer = new h2d.Sprite(s2d);
            
            // can we simplify this?
            var nth_degree = ((360 / names_.length) * i) - 90;
            var radian     = nth_degree * Math.PI / 180;
            tempContainer.x = (s2d.width * 0.5) + R*Math.cos(radian);
            tempContainer.y = (s2d.height* 0.5) + R*Math.sin(radian);
            
            var newtext = new h2d.Text(font, s2d);
            newtext.textColor = 0xFFFFFF;
            newtext.text = s;
            newtext.textAlign = Center;
            newtext.y = -FSIZE/2; //hack for vertical alignment 
            
            tempContainer.addChild(newtext);
            
            texts_.push(newtext);
            i += 1;
        }
    }
    
    static function main() {
        hxd.Res.initEmbed();
        new Test1();
    }
}
