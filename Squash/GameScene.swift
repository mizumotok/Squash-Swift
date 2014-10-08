//
//  GameScene.swift
//  Squash
//
//  Created by Kiyoshi Mizumoto on 2014/10/07.
//  Copyright (c) 2014年 Andgenie Co., Ltd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var paddle: SKSpriteNode!
    var balls = [SKShapeNode]()
    let radius: CGFloat = 12.0
    let numberOfBalls = 3
    let ballSpeed: Double = 600.0
    let time  = SKLabelNode()
    var startTime = NSDate()
    
    override func didMoveToView(view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.paddle = SKSpriteNode(color: UIColor.brownColor(), size: CGSizeMake(100, 20))
        self.paddle.position = CGPointMake(CGRectGetMidX(self.frame), 40.0);
        self.paddle.physicsBody = SKPhysicsBody(rectangleOfSize: self.paddle.size)
        self.paddle.physicsBody!.dynamic = false
        self.addChild(paddle)
        
        addBall()

        self.time.position = CGPointMake(CGRectGetMaxX(self.frame) - 30.0, CGRectGetMaxY(self.frame) - 30.0)
        self.time.fontColor = UIColor.whiteColor()
        self.time.text = "0"
        self.time.fontSize = 100
        self.time.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        self.time.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(self.time)
    }
    
    private func addBall() {
        var directionX: Double = 1;
        for i in 0..<self.numberOfBalls {
            let ball = SKShapeNode(circleOfRadius: radius)
            ball.position = CGPointMake(CGRectGetMidX(self.paddle.frame), CGRectGetMaxY(self.paddle.frame) + radius)
            ball.fillColor = UIColor.yellowColor()
            ball.strokeColor = UIColor.clearColor()
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            
            let randX = arc4random_uniform(10) + 10
            let randY = arc4random_uniform(10) + 10
            let randV = sqrt(Double(randX * randX + randY * randY))
            let speedX = Double(randX) * self.ballSpeed / randV
            let speedY = Double(randY) * self.ballSpeed / randV
            ball.physicsBody!.velocity = CGVectorMake(CGFloat(speedX * directionX), CGFloat(speedY))
            directionX *= -1
            
            ball.physicsBody!.affectedByGravity = false
            ball.physicsBody!.restitution = 1.0
            ball.physicsBody!.linearDamping = 0
            ball.physicsBody!.friction = 0
            ball.physicsBody!.allowsRotation = false
            ball.physicsBody!.usesPreciseCollisionDetection = true

            self.addChild(ball)
            self.balls.append(ball)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if balls.count > 0 {
            self.time.text = String(Int(NSDate().timeIntervalSinceDate(self.startTime)*10))
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.balls.count == 0 {
            startTime = NSDate()
            addBall()
        } else {
            super.touchesBegan(touches, withEvent: event)
            
            let touch = touches.anyObject() as UITouch
            let location = touch.locationInNode(self)
            let speed: CGFloat = 0.001
            let duration = NSTimeInterval(abs(location.x - self.paddle.position.x) * speed)
            let move = SKAction.moveToX(location.x, duration: duration)
            self.paddle.runAction(move)
        }
    }
    
    override func didSimulatePhysics() {
        var removed = [Int]()
        for i in 0..<balls.count {
            let ball = balls[i]
            if ball.position.y < self.radius * 3 {
                let sparkNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!)  as SKEmitterNode
                sparkNode.position = ball.position
                sparkNode.xScale = 0.3
                sparkNode.yScale = 0.3
                self.addChild(sparkNode)
                let fadeOut = SKAction.fadeOutWithDuration(0.3)
                let remove = SKAction.removeFromParent()
                sparkNode.runAction(SKAction.sequence([fadeOut, remove]))
                removed.append(i)
                ball.removeFromParent()
                
            } else {
                let threashold = CGFloat(ballSpeed * 0.1)
                if abs(ball.physicsBody!.velocity.dx) < threashold {
                    let vY  = Double(ball.physicsBody!.velocity.dy) * 0.8
                    ball.physicsBody!.velocity.dx = CGFloat(sqrt(ballSpeed * ballSpeed - vY * vY))
                    ball.physicsBody!.velocity.dy = CGFloat(vY)
                }
                if (abs(ball.physicsBody!.velocity.dy) <  threashold) {
                    let vX = Double(ball.physicsBody!.velocity.dx) * 0.8
                    ball.physicsBody!.velocity.dx = CGFloat(vX)
                    ball.physicsBody!.velocity.dy = CGFloat(sqrt(ballSpeed * ballSpeed - vX * vX))
                }
            }
        }
        for i in removed {
            balls.removeAtIndex(i)
        }
    }
}
