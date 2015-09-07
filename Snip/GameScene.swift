//
//  GameScene.swift
//  Snip
//
//  Created by Christian Ayscue on 11/19/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import SpriteKit
import UIKit
import CoreMotion
import Foundation
import AVFoundation

//.575

struct Enemy {
    var character: SKSpriteNode
    var label: SKLabelNode
    var topArrow: SKSpriteNode
    var sideArrow: SKSpriteNode
}

class GameScene: SKScene {
    
    //UI Nodes
    var _leftBar: SKSpriteNode
    var _topRuler: SKSpriteNode
    var _sideRuler: SKSpriteNode
    var _topCorner: SKSpriteNode
    var _mapView: SKSpriteNode
    var _scope: SKSpriteNode
    var _snipButton: SKSpriteNode
    var _newGameButton: SKSpriteNode
    var _buttonNode: SKSpriteNode
    var _demoButton: SKSpriteNode
    var _startButton: SKSpriteNode
    var _demoLabel: SKLabelNode
    var _tapNode: SKSpriteNode
    
    //Map nodes
    var _map: SKSpriteNode
    var _mountains: SKSpriteNode
    var _pyramid_tree: SKSpriteNode
    var _clouds_sun: SKSpriteNode
    var _waters_dune: SKSpriteNode
    
    //end of game nodes
    var _shotLabel: SKLabelNode
    var _killingLabel: SKLabelNode
    var _killsLabel: SKLabelNode
    var _blood: SKSpriteNode
    
    //helper variables
    var _zoomed: Bool
    var _lastPos: CGPoint
    var _mapView_wthr: CGFloat
    var _body_wthr: CGFloat
    var _mapPos: CGPoint
    var _scopeMoving: Bool
    var _zooming: Bool
    var _activationTimer: NSTimer
    var _dt: CFTimeInterval
    var _lastUpdateTime: CFTimeInterval
    var _kills: Int
    var _gameOver: Bool
    var _gameStarted: Bool
    var _bloodEmitter: SKEmitterNode
    var _motionManager: CMMotionManager
    var _xRotation: Float
    var _yRotation: Float
    var _zRotation: Float
    var _timers: Dictionary<String, NSTimer>
    var _times: Dictionary<String, NSTimeInterval>
    var _mode: String
    var _shotSoundPlayer: AVAudioPlayer
    
    //timer variables
    var timeToShoot: Float = 6
    var respawnTime: Float = 4
    var timeToScroll: NSTimeInterval = 0.5
    
    //seting up dictionary and array to access enemies
    var _enemyDictionary: [String:Enemy]
    var _enemyNameArray: [String]
    var _activeEnemiesArray: [String]
    
    required init?(coder aDecoder: NSCoder) {
        
        var error: NSError? = NSError()
        var shot = NSBundle.mainBundle().URLForResource("sniper_rifle.mp3", withExtension:nil);
        _shotSoundPlayer = AVAudioPlayer(contentsOfURL: shot,
            error: &error)
        _shotSoundPlayer.numberOfLoops = 0
        _shotSoundPlayer.volume = 0.7
        _shotSoundPlayer.prepareToPlay()
        
        _leftBar = SKSpriteNode()
        _topRuler = SKSpriteNode()
        _sideRuler = SKSpriteNode()
        _topCorner = SKSpriteNode()
        _mapView = SKSpriteNode()
        _scope = SKSpriteNode()
        _snipButton = SKSpriteNode()
        _buttonNode = SKSpriteNode()
        _demoButton = SKSpriteNode()
        _startButton = SKSpriteNode()
        _demoLabel = SKLabelNode()
        _tapNode = SKSpriteNode()
        
        _map = SKSpriteNode()
        _mountains = SKSpriteNode()
        _pyramid_tree = SKSpriteNode()
        _clouds_sun = SKSpriteNode()
        _waters_dune = SKSpriteNode()
        
        _shotLabel = SKLabelNode()
        _killingLabel = SKLabelNode()
        _killsLabel = SKLabelNode()
        _blood = SKSpriteNode()
        _bloodEmitter = SKEmitterNode()
        
        
        _zoomed = false
        _lastPos = CGPointMake(0,0)
        _mapView_wthr = 0
        _body_wthr = 0.468
        _mapPos = CGPointMake(0,0)
        _scopeMoving = false
        _zooming = false
        _activationTimer = NSTimer()
        _lastUpdateTime = 0
        _dt = 0
        _kills = 0
        _gameOver = false
        _gameStarted = false
        _motionManager = CMMotionManager()
        _xRotation = 0
        _yRotation = 0
        _zRotation = 0
        _timers = [String: NSTimer]()
        _times = [String: NSTimeInterval]()
        _activeEnemiesArray = [String]()
        _mode = "game"
        
//        for var i = 0; i < 8; i += 1{
//            _timers.append(nil)
//            _times.append(nil)
//        }
        
        _enemyDictionary = [String:Enemy]()
        _enemyNameArray = ["pyramid door", "right lake", "left lake", "low tree", "mid tree", "high tree", "random dune", "pyramid top", "behind dune left", "behind dune right", "behind right river", "behind left river", "mountain 1", "mountain 2", "mountain 3", "mountain 4", "clouds 1", "clouds 2", "sun"]
        _newGameButton = SKSpriteNode()
        super.init(coder: aDecoder)
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        var scaleDown = SKAction.scaleTo(0.7, duration: 0.5)
        scaleDown.timingMode = SKActionTimingMode.EaseInEaseOut
        var scaleUp = SKAction.scaleTo(1, duration: 0.5)
        scaleUp.timingMode = SKActionTimingMode.EaseInEaseOut
        
        self._tapNode = SKSpriteNode(imageNamed: "tap.png")
        self._tapNode.size = CGSizeMake(100, 100)
        self._tapNode.runAction(SKAction.repeatActionForever(SKAction.sequence([scaleDown,scaleUp])))
        _tapNode.alpha = 0
        
        self._tapNode.zPosition = 2500
        self.addChild(self._tapNode)
        
        //set up UI
        _leftBar = SKSpriteNode(texture: SKTexture(imageNamed: "left_bar.png"), size: CGSizeMake(self.size.width*0.25, self.size.height))
        _leftBar.anchorPoint = CGPointMake(0,0)
        _leftBar.position = CGPointZero
        _leftBar.zPosition = 1000
        
        _topRuler = SKSpriteNode(texture: SKTexture(imageNamed: "ruler.png"), size: CGSizeMake(self.size.width*0.75-self.size.height*0.05, self.size.height*0.05))
        _topRuler.anchorPoint = CGPointMake(0,1)
        _topRuler.position = CGPointMake(self.size.width*0.25, self.size.height*1)
        _topRuler.zPosition = 1000
        
        _sideRuler = SKSpriteNode(texture: SKTexture(imageNamed: "ruler.png"), size: CGSizeMake(self.size.height*0.95, self.size.height*0.05))
        _sideRuler.anchorPoint = CGPointMake(0,1)
        _sideRuler.position = CGPointMake(self.size.width, self.size.height*0.95)
        _sideRuler.zRotation = CGFloat(-M_PI/2)
        _sideRuler.zPosition = 1000
        
        _topCorner = SKSpriteNode(texture: SKTexture(imageNamed: "left_bar.png"), size: CGSizeMake(self.size.height*0.05, self.size.height*0.05))
        _topCorner.anchorPoint = CGPointMake(1,1)
        _topCorner.position = CGPointMake(self.size.width, self.size.height)
        _topCorner.zPosition = 1000
        
        _mapView = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(self.size.width*0.75-self.size.height*0.05, self.size.height*0.95))
        _mapView.anchorPoint = CGPointZero
        _mapView.position = CGPointMake(self.size.width*0.25, 0)
        _mapView_wthr = _mapView.size.width/_mapView.size.height
        
        _scope = SKSpriteNode(texture: SKTexture(imageNamed: "scope.png"), size: CGSizeMake(self.size.height*4*1.1
            , self.size.height*4))
        _scope.zPosition = 800
        _scope.position = CGPointMake(_mapView.size.width/2, _mapView.size.height/2)
        _scope.alpha = 0
        
        _snipButton = SKSpriteNode(texture: SKTexture(imageNamed: "snip_button.png"), size: CGSizeMake(self.size.width*0.2, self.size.width*0.2/1.8))
        _snipButton.position = CGPointMake(self.size.width*0.122, -self.size.height*0.88)
        _snipButton.zPosition = 1100
        
        //set up map
        //base node - changing attributes changes attributes of other child nodes
        _map = SKSpriteNode(texture: SKTexture(imageNamed: "base_node.png"), size: CGSizeMake(_mapView.size.height*1.54, _mapView.size.height)) //sets the base node for the map (its the sky)
        _map.anchorPoint = CGPointZero
        _map.position = CGPointMake(0, _mapView.size.height*0.17)
        
        _clouds_sun = SKSpriteNode(texture: SKTexture(imageNamed: "sun+clouds.png"), size: _map.size)
        _clouds_sun.zPosition = 100
        _clouds_sun.anchorPoint = CGPointZero
        _clouds_sun.position = CGPointZero
        
        _mountains = SKSpriteNode(texture: SKTexture(imageNamed: "mountains.png"), size: _map.size)
        _mountains.zPosition = 200
        _mountains.anchorPoint = CGPointZero
        _mountains.position = CGPointZero
        
        _waters_dune = SKSpriteNode(texture: SKTexture(imageNamed: "waters+dune+door.png"), size: _map.size)
        _waters_dune.zPosition = 300
        _waters_dune.anchorPoint = CGPointZero
        _waters_dune.position = CGPointZero
        
        _pyramid_tree = SKSpriteNode(texture: SKTexture(imageNamed: "pyramid+tree+lake_blocker.png"), size: _map.size)
        _pyramid_tree.zPosition = 400
        _pyramid_tree.anchorPoint = CGPointZero
        _pyramid_tree.position = CGPointZero
        
        //add death scene nodes
        _shotLabel = SKLabelNode(text: "You got shot!")
        _shotLabel.fontSize = 60
        _shotLabel.fontName = "Webdings"
        _shotLabel.position = CGPointMake(_mapView.size.width/2, _mapView.size.height*0.62)
        _shotLabel.zPosition = 950
        _shotLabel.alpha = 0
        _killingLabel = SKLabelNode(text: "But not before killing")
        _killingLabel.fontSize = 60
        _killingLabel.fontName = "Webdings"
        _killingLabel.position = CGPointMake(_mapView.size.width/2, _mapView.size.height*0.47)
        _killingLabel.zPosition = 950
        _killingLabel.alpha = 0
        _killsLabel.fontSize = 80
        _killsLabel.fontName = "Webdings"
        _killsLabel.position = CGPointMake(_mapView.size.width/2, _mapView.size.height*0.3)
        _killsLabel.zPosition = 950
        _killsLabel.alpha = 0
        _blood = SKSpriteNode(texture: SKTexture(imageNamed: "blood.png"), size: CGSizeMake(self.size.width*0.9, self.size.height*1.3))
        _blood.anchorPoint = CGPointMake(1,1)
        _blood.zPosition = 900
        _blood.position = CGPointMake(_mapView.size.width*1.1, _mapView.size.height*2.4)
        _mapView.addChild(_blood)
        
        //sets up the blood emitter
        _bloodEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("Blood", ofType:"sks")!) as SKEmitterNode
        _bloodEmitter.zPosition = 700
        _map.addChild(_bloodEmitter)
        _bloodEmitter.alpha = 0
        //set up game start
        
        _buttonNode = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(0,0))
        _buttonNode.anchorPoint = CGPointZero
        _buttonNode.position = CGPointZero
        _buttonNode.zPosition = 1000
        
        //make start and demo buttons visible and record label
        _startButton = SKSpriteNode(texture: SKTexture(imageNamed: "start_button.png"), size: _snipButton.size)
        _startButton.position = CGPointMake(_snipButton.position.x, self.size.height/2)
        _startButton.zPosition = 1100
        
        _demoButton = SKSpriteNode(texture: SKTexture(imageNamed: "demo_button.png"), size: _snipButton.size)
        _demoButton.position = CGPointMake(_snipButton.position.x, _snipButton.position.y + self.size.height)
        _demoButton.zPosition = 1100
        
        var recordLabel = SKLabelNode(text: "High Score:")
        recordLabel.fontName = "Webdings"
        recordLabel.fontSize = 45
        recordLabel.position = CGPointMake(_snipButton.position.x, self.size.height*0.85)
        recordLabel.zPosition = 1100
        
        var kill: Int = NSUserDefaults.standardUserDefaults().integerForKey("record")
        var kills = SKLabelNode(text: "\(kill) kills")
        kills.fontName = "Webdings"
        kills.fontSize = 55
        kills.position = CGPointMake(_snipButton.position.x, self.size.height*0.76)
        kills.zPosition = 1100
        
        //sidebar has new game button
        _newGameButton = SKSpriteNode(texture: SKTexture(imageNamed: "new_game_button.png"), size: CGSizeMake(_snipButton.size.width, 0.688*_snipButton.size.width))
        _newGameButton.position = CGPointMake(_snipButton.position.x, self.size.height*0.47-2*self.size.height)
        _newGameButton.zPosition = 1100
        
        _buttonNode.addChild(_newGameButton)
        _buttonNode.addChild(_startButton)
        _buttonNode.addChild(_demoButton)
        _buttonNode.addChild(recordLabel)
        _buttonNode.addChild(kills)
        _buttonNode.addChild(_snipButton)
        
        
        //sets up demo label
        _demoLabel.position = CGPointMake(self._mapView.size.width/2, self._mapView.size.height*0.9)
        _demoLabel.color = UIColor.whiteColor()
        _demoLabel.zPosition = 2000
        _demoLabel.fontName = "System-Bold"
        _demoLabel.fontSize = 50
        _demoLabel.alpha = 0
        _mapView.addChild(self._demoLabel)
        
        //if user is new, prompt to do demo
        if NSUserDefaults.standardUserDefaults().boolForKey("New user?") == true {            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "New user?")
            _demoLabel.text = "Tap \"Demo\" for instructions."
            _demoLabel.alpha = 1
        }
        
        //make record visible
        //make make instructions button visible
        
        //add layers to sky node (base node)
        _map.addChild(_clouds_sun)
        _map.addChild(_mountains)
        _map.addChild(_waters_dune)
        _map.addChild(_pyramid_tree)
        _mapView.addChild(_shotLabel)
        _mapView.addChild(_killingLabel)
        _mapView.addChild(_killsLabel)
        _map.setScale(0.66)
        
        //add map and scope to the mapView
        _mapView.addChild(_map)
        _mapView.addChild(_scope)
        
        //add map and UIElements to the view
        self.addChild(_mapView)
        self.addChild(_leftBar)
        self.addChild(_topRuler)
        self.addChild(_sideRuler)
        self.addChild(_topCorner)
        self.addChild(_buttonNode)
        
        //make backgound to everything
        var background = SKSpriteNode(texture:SKTexture(imageNamed:"bg.png"), size: CGSizeMake(self.size.width, self.size.height))
        background.anchorPoint = CGPointZero
        background.position = CGPointZero
        background.zPosition = -100
        self.addChild(background)
        
        //set up enemies
        _enemyDictionary.updateValue(createEnemy(171, yPosition: 95, angle: 30, side: -1, size: 1, zPos:350), forKey: "pyramid door")
        _enemyDictionary.updateValue(createEnemy(668, yPosition: 78, angle: 0, side: -1, size: 2, zPos:350), forKey: "right lake")
        _enemyDictionary.updateValue(createEnemy(555, yPosition: 76, angle: 0, side: 1, size: 2, zPos:350), forKey: "left lake")
        _enemyDictionary.updateValue(createEnemy(771, yPosition: 115, angle: -45, side: 1, size: 2, zPos:350), forKey: "low tree")
        _enemyDictionary.updateValue(createEnemy(690, yPosition: 146, angle: 80, side: -1, size: 2, zPos:350), forKey: "mid tree")
        _enemyDictionary.updateValue(createEnemy(779, yPosition: 180, angle: 200, side: -1, size: 2, zPos:350), forKey: "high tree")
        _enemyDictionary.updateValue(createEnemy(950, yPosition: 124, angle: 0, side: 1, size: 2, zPos:350), forKey: "random dune")
        _enemyDictionary.updateValue(createEnemy(206, yPosition: 245, angle: -30, side: -1, size: 2, zPos:350), forKey: "pyramid top")
        _enemyDictionary.updateValue(createEnemy(82, yPosition: 224, angle: -15, side: 1, size: 2, zPos:250), forKey: "behind dune left")
        _enemyDictionary.updateValue(createEnemy(868, yPosition: 241, angle: 0, side: 1, size: 2, zPos: 250), forKey: "behind dune right")
        _enemyDictionary.updateValue(createEnemy(940, yPosition: 314, angle: 10, side: -1, size: 1, zPos: 250), forKey: "behind right river")
        _enemyDictionary.updateValue(createEnemy(294, yPosition: 430, angle: -15, side: -1, size: 1, zPos: 250), forKey: "behind left river")
        _enemyDictionary.updateValue(createEnemy(104, yPosition: 542, angle: 30, side: -1, size: 2, zPos: 150), forKey: "mountain 1")
        _enemyDictionary.updateValue(createEnemy(298, yPosition: 510, angle: 20, side: -1, size: 2, zPos: 150), forKey: "mountain 2")
        _enemyDictionary.updateValue(createEnemy(477, yPosition: 617, angle: -30, side: 1, size: 2, zPos: 150), forKey: "mountain 3")
        _enemyDictionary.updateValue(createEnemy(781, yPosition: 483, angle: -30, side: 1, size: 2, zPos: 150), forKey: "mountain 4")
        _enemyDictionary.updateValue(createEnemy(234, yPosition: 687, angle: -20, side: 1, size: 2, zPos: 150), forKey: "clouds 1")
        _enemyDictionary.updateValue(createEnemy(751, yPosition: 606, angle: -150, side: -1, size: 2, zPos: 150), forKey: "clouds 2")
        _enemyDictionary.updateValue(createEnemy(1003, yPosition: 605, angle: 160, side: 1, size: 2, zPos: 50), forKey: "sun")
        
        //add enemies to map
        for var i = 0; i < 19; i++ {
            _map.addChild(_enemyDictionary[_enemyNameArray[i]]!.character)
            var enemy = _enemyDictionary[_enemyNameArray[i]]
        }
        
//        //if user is new, start the demo
//        if NSUserDefaults.standardUserDefaults().boolForKey("New user?") == true {
//            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "New user?")
//            startDemo()
//        }
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        var location = CGPoint()
        for touch: AnyObject in touches {
            location = touch.locationInNode(_mapView)
        }
        if(!_gameOver){
            
            //if demo button is pressed
            if (!_gameStarted && location.x < 0 && location.y < 0.35*self.size.height){
                //starts the game in demo mode
                
                //_demoButton.texture = SKTexture(imageNamed: "demo_button_pressed")
                _demoLabel.text = "Tap where arrows point to enemy"
                    
                _mode = "demo"
                timeToShoot = 100
                //set baseline accelerometer data
                _zRotation = asinf(Float(_motionManager.accelerometerData.acceleration.z))
                _yRotation = asinf(Float(_motionManager.accelerometerData.acceleration.y))
                
                _gameStarted = true
                _zooming = true
                
                //constants to help with zooming effect
                let mapWidth = _map.size.width
                let mapHeight = _map.size.height
                
                var slide = SKAction.moveByX(0, y: self.size.height, duration: 0.4)
                slide.timingMode = SKActionTimingMode.EaseOut
                _buttonNode.runAction(slide)
                _map.runAction(SKAction.scaleTo(3, duration: 1))//zooms map in
                
                _scope.runAction(SKAction.scaleTo(0.7, duration: 1))//scales scope (zoom in effect)
                _scope.runAction(SKAction.fadeAlphaTo(0.85, duration: 1), completion: { () -> Void in
                    self._zooming = false
                    
                })//fades and zooms scope in
                
                var xPosition = CGFloat(-_scope.position.x/_mapView.size.width*_map.size.width*CGFloat(4.55)+_scope.position.x)
                var yPosition = CGFloat(-_scope.position.y/_mapView.size.height*_map.size.height*CGFloat(4.55)+_scope.position.y)
                _mapPos = CGPointMake(xPosition, yPosition)
                //converts point to point on mapview
                _map.runAction(SKAction.moveTo(_mapPos, duration: 1))
                _scopeMoving = true
                _scope.runAction(SKAction.moveTo(CGPointMake(_mapView.size.width/CGFloat(2), _mapView.size.height/CGFloat(2)), duration: 1), completion: { () -> Void in
                    self._scopeMoving = false
                    self._demoLabel.alpha = 1
                    self._tapNode.alpha = 1
                    
                    self._activationTimer = NSTimer.scheduledTimerWithTimeInterval(100, target: self, selector: "activateEnemy:", userInfo: nil, repeats: true)
                    self._activationTimer.fire()
                    self._activationTimer.invalidate()
                })
                
            }
            //if start button is pressed, zoom in
            if (!_gameStarted && location.x < 0 && location.y < 0.65*self.size.height && location.y > 0.35*self.size.height){
                
                //set baseline accelerometer data
                _zRotation = asinf(Float(_motionManager.accelerometerData.acceleration.z))
                _yRotation = asinf(Float(_motionManager.accelerometerData.acceleration.y))
                
                _gameStarted = true
                _zooming = true
                
                _demoLabel.alpha = 0
                
                //constants to help with zooming effect
                let mapWidth = _map.size.width
                let mapHeight = _map.size.height
                
                var slide = SKAction.moveByX(0, y: self.size.height, duration: 0.4)
                slide.timingMode = SKActionTimingMode.EaseOut
                _buttonNode.runAction(slide)
                _map.runAction(SKAction.scaleTo(3, duration: 1))//zooms map in
                
                _scope.runAction(SKAction.scaleTo(0.7, duration: 1))//scales scope (zoom in effect)
                _scope.runAction(SKAction.fadeAlphaTo(0.85, duration: 1), completion: { () -> Void in
                    self._zooming = false
                })//fades and zooms scope in
                
                var xPosition = CGFloat(-_scope.position.x/_mapView.size.width*_map.size.width*CGFloat(4.55)+_scope.position.x)
                var yPosition = CGFloat(-_scope.position.y/_mapView.size.height*_map.size.height*CGFloat(4.55)+_scope.position.y)
                _mapPos = CGPointMake(xPosition, yPosition)
                //converts point to point on mapview
                _map.runAction(SKAction.moveTo(_mapPos, duration: 1))
                
                _scopeMoving = true
                _scope.runAction(SKAction.moveTo(CGPointMake(_mapView.size.width/CGFloat(2), _mapView.size.height/CGFloat(2)), duration: 1), completion: { () -> Void in
                    self._scopeMoving = false
                    self._activationTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.respawnTime), target: self, selector: "activateEnemy:", userInfo: nil, repeats: true)
                    self._activationTimer.fire()
                })
            }else{
                //shoot
                if(_gameStarted && location.x < 0 && location.y < 0.16*self.size.width && !_scopeMoving){
                    
                    //sound effect
                    _shotSoundPlayer.stop()
                    _shotSoundPlayer.currentTime = 0
                    _shotSoundPlayer.play()
                    
                    _snipButton.texture = SKTexture(imageNamed: "snip_button_pressed.png")
                    
                    //recoil effect
                    var recoil1 = SKAction.moveByX(0, y: 50, duration: 0.1)
                    var recoil2 = SKAction.moveByX(0, y: -50, duration: 0.2)
                    recoil1.timingMode = SKActionTimingMode.EaseOut
                    recoil2.timingMode = SKActionTimingMode.EaseIn
                    _scopeMoving = true
                    _scope.removeAllActions()
                    _scope.runAction(SKAction.sequence([recoil1, recoil2]), completion: { () -> Void in
                        self._scopeMoving = false
                    })

                    var shotPos:CGPoint = CGPointMake((_scope.position.x/_mapView.size.width)*(_map.size.width/3), (_scope.position.y/_mapView.size.height)*(_map.size.height/3))
                    
                    //for every active enemy, check if the are shot and respond apropriately
                    for enemyName in _activeEnemiesArray{
                        if var enemyObj = _enemyDictionary[enemyName]{
                            var enemy = enemyObj.character as SKSpriteNode
                            var enemyIndex = find(_activeEnemiesArray, enemyName)!
                            
                            //if the shot was inside the circle
                            var circleRad = pow(shotPos.x-enemy.position.x, 2)+pow(shotPos.y-enemy.position.y, 2)
                            if (circleRad < pow(20*_body_wthr,2)){
                                //make the blood pour
                                var xPosition = CGFloat(_scope.position.x/_mapView.size.width*_map.size.width/3)
                                var yPosition = CGFloat(_scope.position.y/_mapView.size.height*_map.size.height/3)
                                _bloodEmitter.position = CGPointMake(xPosition, yPosition)
                                _bloodEmitter.alpha = 1
                                
                                //_bloodEmitter.removeAllActions()
                                _bloodEmitter.runAction(SKAction.fadeAlphaTo(0, duration: 1.5))
                                
                                //remove enemy and reset timer and time
                                enemy.runAction(SKAction.fadeAlphaTo(0, duration: 1.5))
                                
                                //invalidates the correct timer
                                for (name,timer) in _timers{
                                    if (name == enemyName){
                                        _timers[name]?.invalidate()
                                        _timers.removeValueForKey(name)
                                        break;
                                    }
                                }

                                //remove Label and arrows
                                enemyObj.topArrow.alpha = 0;
                                enemyObj.sideArrow.alpha = 0;
                                
                                enemyObj.label.runAction(SKAction.fadeAlphaTo(0, duration: 0.5),completion:{()->Void in
                                    enemyObj.label.position = CGPointMake(self.size.width*0.125, -self.size.height*0.2)
                                })
                                
                                if self._mode == "demo"{
                                    self._demoLabel.text = "Good job!"
                                    self._tapNode.removeAllActions()
                                    self.runAction(SKAction.waitForDuration(1), completion: { () -> Void in
                                        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene{
                                            scene.scaleMode = .Fill
                                            scene._motionManager = self._motionManager
                                            self.view!.presentScene(scene)
                                        }
                                    })
                                }
                                
                                
                                //removes the enemy from activeEnemies
                                for var i:Int = enemyIndex; i <  _activeEnemiesArray.count-1; i += 1{
                                    _activeEnemiesArray[i] = _activeEnemiesArray[i+1];
                                    var enemy = _enemyDictionary[_activeEnemiesArray[i]]
                                    var yPos = CGFloat(self.size.height-self.size.height*0.2*CGFloat(i+1))
                                    enemy?.label.removeAllActions()
                                    enemy?.label.runAction(SKAction.moveToY(yPos, duration: 0.7))
                                }
                                _activeEnemiesArray.removeAtIndex(_activeEnemiesArray.count - 1)
                                //increment kills
                                _kills++
                            }
                        }
                    }
                    //aim scope at tap
                }else if(_gameStarted && location.x < _mapView.size.width && location.x > 0 && location.y < _mapView.size.height && location.y > 0){
                    var xPosition = CGFloat(-location.x/_mapView.size.width*_map.size.width+location.x)
                    var yPosition = CGFloat(-location.y/_mapView.size.height*_map.size.height+location.y)
                    _mapPos = CGPointMake(xPosition, yPosition) //converts point to point on mapview
                    if (_mode == "demo"){
                        self._tapNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
                        _demoLabel.runAction(SKAction.fadeAlphaTo(0, duration: 0.5), completion: { () -> Void in
                                self._demoLabel.text = "Tilt iPhone to adjust aim"
                                self._demoLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
                                self.runAction(SKAction.waitForDuration(2), completion: { () -> Void in
                                    self._demoLabel.text = "Tap \"Snip\" button to shoot"
                                    self._tapNode.alpha = 1
                                    self._tapNode.position = CGPointMake(self._leftBar.size.width/2, self._leftBar.size.height*0.13)
                                })
                            })
                    }
                    //move the map
                    var moveMap = SKAction.moveTo(_mapPos, duration: timeToScroll)
                    moveMap.timingMode = SKActionTimingMode.EaseOut
                    _map.runAction(moveMap)
                    
                    //move the scope
                    var moveScope = SKAction.moveTo(location, duration: timeToScroll)
                    moveScope.timingMode = SKActionTimingMode.EaseOut
                    _scopeMoving = true
                    if !_zooming{
                        _scope.removeAllActions()
                    }
                    _scope.runAction(moveScope, completion: { () -> Void in
                        self._scopeMoving = false
                    })
                }
            }
        }else if(location.x < 0 && location.y < self.size.width*0.6 && location.y > self.size.height*0.3){
            _newGameButton.texture = SKTexture(imageNamed: "new_game_button_pressed.png")
            self.runAction(SKAction.waitForDuration(0.01), completion: { () -> Void in
                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene{
                    scene.scaleMode = .Fill
                    scene._motionManager = self._motionManager
                    self.view!.presentScene(scene)
                }
            })
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.runAction(SKAction.waitForDuration(0.01), completion: { () -> Void in
            self._snipButton.texture = SKTexture(imageNamed: "snip_button.png")
            self._newGameButton.texture = SKTexture(imageNamed: "new_game_button.png")
        })
    }
    var i:Int = 0
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        i+=1
        
        if i == 120{
        //print("\(_motionManager.accelerometerData.acceleration.x), \(_motionManager.accelerometerData.acceleration.y), \(_motionManager.accelerometerData.acceleration.z)\n")
        i = 0
        }
        
        if(_lastUpdateTime != 0)
        {
            _dt = currentTime - _lastUpdateTime
        }else
        {
            _dt=0
        }
        _lastUpdateTime = currentTime
        
        
    }
    
    
    override func didSimulatePhysics() {
        if (_zooming){
        }
        if !_scopeMoving && _gameStarted && !_zooming && !_gameOver{
            
            var yChange = _zRotation - asin(Float(_motionManager.accelerometerData.acceleration.z))
            var ySpeed: Float
            if yChange > 0 {
                if yChange > Float(M_PI_4){
                    ySpeed = 200
                }else{
                    ySpeed = 200*(yChange)/(Float(M_PI_4))
                }
            }else{
                if -yChange > Float(M_PI_4){
                    ySpeed = -200
                }else{
                    ySpeed = -200*(-yChange)/(Float(M_PI_4))
                }
            }
            var xChange = Float(_yRotation - asin(Float(_motionManager.accelerometerData.acceleration.y)))
            var xSpeed: Float
            if xChange > 0 {
                if xChange > Float(M_PI_4){
                    xSpeed = -200
                }else{
                    xSpeed = -200*(xChange)/(Float(M_PI_4))
                }
            }else{
                if -xChange > Float(M_PI_4){
                    xSpeed = 200
                }else{
                    xSpeed = 200*(-xChange)/(Float(M_PI_4))
                }
            }
            
            //sets the point of the scope
            var xPosition = CGFloat(_scope.position.x+CGFloat(xSpeed)*CGFloat(_dt))
            var yPosition = CGFloat(_scope.position.y+CGFloat(ySpeed)*CGFloat(_dt))
            
            var location = CGPointMake(xPosition, yPosition)
            
            if location.x < _mapView.size.width && location.x > 0{
                _scope.position = CGPointMake(location.x, _scope.position.y)
                var xPosition = CGFloat(-location.x/_mapView.size.width*_map.size.width+location.x)
                var yPosition = CGFloat(-_scope.position.y/_mapView.size.height*_map.size.height+_scope.position.y)
                _map.position = CGPointMake(xPosition, yPosition)
            }
            if location.y < _mapView.size.height && location.y > 0{
                _scope.position = CGPointMake(_scope.position.x, location.y)
                var xPosition = CGFloat(-_scope.position.x/_mapView.size.width*_map.size.width+_scope.position.x)
                var yPosition = CGFloat(-location.y/_mapView.size.height*_map.size.height+location.y)
                _map.position = CGPointMake(xPosition, yPosition)
            }
        }
    }
    
    //initializes an enemy
    func createEnemy(xPosition: Int, yPosition: Int, angle: Int, side: Int, size: Int, zPos:Int) -> Enemy{
        
        //creates the appropriate body size from the input "size"
        var bodySize = CGSize()
        switch size{
        case 1:
            bodySize = CGSizeMake(30*_body_wthr, 30)
            break
        case 2:
            bodySize = CGSizeMake(40*_body_wthr, 40)
            break
        case 3:
            bodySize = CGSizeMake(50*_body_wthr, 50)
            break
        default:
            
            break
        }
        
        //creates the spritenode with the correct image, anchor point, position, zPosition, and angle
        var character = SKSpriteNode(texture: SKTexture(imageNamed: "body"+String(side)+".png"), size: bodySize)
        if side == -1 {
            character.anchorPoint = CGPointMake(0.575, 1)
        }else{
            character.anchorPoint = CGPointMake(0.425,1)
        }
        character.position = CGPointMake(CGFloat(xPosition), CGFloat(yPosition))
        character.zRotation = CGFloat(M_PI)/CGFloat(180)*CGFloat(angle)
        character.zPosition = CGFloat(zPos)
        
        //adds the head to the body
        var head = SKSpriteNode(texture: SKTexture(imageNamed: "head.png"), size: CGSizeMake(bodySize.width, bodySize.width))
        head.name = "head"
        head.zPosition = -1
        head.position = CGPointZero
        character.addChild(head)
        character.alpha = 0
        
        var flash = SKSpriteNode(texture: SKTexture(imageNamed: "flash.png"), size:CGSizeMake(4*bodySize.height, 2*bodySize.height))
        flash.position = CGPointMake(0.125*bodySize.height*CGFloat(side), -0.225*bodySize.height)
        flash.name = "flash"
        flash.alpha = 0
        flash.zPosition = 100
        character.addChild(flash)

        //creates the other objects
        var coordinate = CGPointMake(100*CGFloat(xPosition)/CGFloat(1122), 100*CGFloat(yPosition)/CGFloat(729))
        var coordX : NSString = NSString(format: "%.f", Float(coordinate.x))
        var coordY : NSString = NSString(format: "%.f", Float(coordinate.y))
        var label = SKLabelNode(text: "[ \(coordX), \(coordY) ]")
        label.fontName = "Webdings"
        label.fontSize = 52
        label.color = SKColor.redColor()
        label.position = CGPointMake(self.size.width*0.125, -self.size.height*0.2)
        label.alpha = 0
        label.zPosition = 1100
        label.runAction(SKAction.fadeAlphaTo(1, duration: 1))
        self.addChild(label)
        
        var topArrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow.png"), size: CGSizeMake(self.size.height*0.05, self.size.height*0.07))
        topArrow.anchorPoint = CGPointMake(0.5, 0)
        topArrow.position = CGPointMake(CGFloat(xPosition)/1.54*_mapView_wthr, 0.95*self.size.height)
        topArrow.zPosition = 1100
        topArrow.alpha = 0
        _mapView.addChild(topArrow)
        
        var sideArrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow.png"), size: CGSizeMake(self.size.height*0.05, self.size.height*0.07))
        sideArrow.anchorPoint = CGPointMake(0.5, 0)
        sideArrow.zRotation = CGFloat(-M_PI_2)
        sideArrow.position = CGPointMake(_mapView.size.width, CGFloat(yPosition))
        sideArrow.zPosition = 1100
        sideArrow.alpha = 0
        _mapView.addChild(sideArrow)

        var enemy = Enemy(character: character, label: label, topArrow: topArrow, sideArrow: sideArrow)
        
        return enemy
    }
    
    //an enemy becomes a threat
    func activateEnemy(timer: NSTimer){
        
        //shortens how long it takes the enemy to shoot
        if timeToShoot > 4{
            timeToShoot *= 0.95
        }
        
        if respawnTime > 3 {
            respawnTime *= 0.95
            timeToScroll *= 0.95
            timer.invalidate()
            self._activationTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(respawnTime), target: self, selector: "activateEnemy:", userInfo: nil, repeats: true)
        }
        
        //make random enemy appear
        var randIndex: Int
        do{
            randIndex = Int(arc4random_uniform(19))
        }while(contains(_activeEnemiesArray, _enemyNameArray[randIndex]))
        
        _activeEnemiesArray.append(_enemyNameArray[randIndex])
        var enemy = _enemyDictionary[_enemyNameArray[randIndex]]!
        enemy.character.removeAllActions()
        enemy.character.alpha = 1
        
        if _mode == "demo"{
            _tapNode.position = CGPointMake(self._leftBar.size.width + enemy.topArrow.position.x, enemy.sideArrow.position.y)
            println(_tapNode.position)
        }
        
        //add coordinates to left view
        var slideIn = SKAction.moveTo(CGPointMake(self.size.width*0.125, self.size.height-self.size.height*CGFloat(_activeEnemiesArray.count)*0.2), duration: 0.7)
        slideIn.timingMode = SKActionTimingMode.EaseOut
        enemy.label.alpha = 1
        enemy.label.runAction(slideIn)
        
        
        
        //set timer to start to show red pointers on rulers when enemy gets closer to shooting - when this timer expires, enemy shoots
        var newTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "countDown:", userInfo: _enemyNameArray[randIndex], repeats: true)
        _timers.updateValue(newTimer, forKey: _enemyNameArray[randIndex])
        _times.updateValue(0, forKey: _enemyNameArray[randIndex])
    }
    
    
    //count down to shot
    func countDown(timer: NSTimer){
        if(_gameOver){
            timer.invalidate()
        }else{
            
            var enemyName: String = timer.userInfo as String
            var enemy: Enemy = _enemyDictionary[enemyName]!
            var time: NSTimeInterval = _times[enemyName]!
            time += 0.2
            //for demo mode
            if _mode == "demo"{
                time = 80
            }
            _times.updateValue(time, forKey: enemyName)

            enemy.label.colorBlendFactor = CGFloat(powf(Float(time)/Float(timeToShoot), 1.5))
            enemy.topArrow.alpha = CGFloat(Float(time)/Float(timeToShoot))
            enemy.sideArrow.alpha = CGFloat(Float(time)/Float(timeToShoot))
            
            _enemyDictionary[enemyName] = enemy
            
            //when enemy shoots
            if(Float(time) >= Float(timeToShoot)){
                
                //sound effect
                _shotSoundPlayer.stop()
                _shotSoundPlayer.volume = 0.1
                _shotSoundPlayer.currentTime = 0
                _shotSoundPlayer.play()
                
                //flash from enemy's gun
                var flash = enemy.character.childNodeWithName("flash") as SKSpriteNode
                flash.alpha = 0.9
                flash.runAction(SKAction.waitForDuration(0.2), completion:{()->Void in
                    flash.alpha = 0
                })
                
                //crack on scope and blood over screen
                
                var bloodEye:SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "blood_eye"), size: _mapView.size)
                bloodEye.anchorPoint = CGPointZero
                bloodEye.position = CGPointZero
                bloodEye.zPosition = 850
                
                _mapView.addChild(bloodEye)
                _blood.runAction(SKAction.moveToY(self.size.height, duration: 1.5))
                
                for (name, timer) in _timers{
                    timer.invalidate()
                }
                
                //remove sidebar items and arrows
                for enemyN: String in _activeEnemiesArray{
                    if enemyN != ""{
                        var enemy = _enemyDictionary[enemyN]! as Enemy
                        enemy.topArrow.alpha = 0
                        enemy.sideArrow.alpha = 0
                        enemy.label.alpha = 0
                    }
                }
                _activationTimer.invalidate()
             
                //you got shot, but not before killing x enemies
                var fadeIn = SKAction.fadeAlphaTo(1, duration: 1.5)
                fadeIn.timingMode = SKActionTimingMode.EaseIn
                _shotLabel.runAction(fadeIn)
                _killingLabel.runAction(fadeIn)
                _killsLabel.text = "\(_kills) snipers"
                _killsLabel.runAction(fadeIn)
                var slide = SKAction.moveByX(0, y: self.size.height, duration: 0.4)
                slide.timingMode = SKActionTimingMode.EaseOut
                _buttonNode.runAction(slide)
                
                if (NSUserDefaults.standardUserDefaults().integerForKey("record") < _kills){
                    NSUserDefaults.standardUserDefaults().setInteger(_kills, forKey: "record")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                _gameOver = true
            }
        }
    }
}
