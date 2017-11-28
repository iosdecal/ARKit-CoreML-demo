//
//  ViewController.swift
//  ARTicTacToe
//
//  Created by Gokul Swamy on 11/24/17.
//  Copyright © 2017 Gokul Swamy. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    var board = ["", "", "",
                 "", "", "",
                 "", "", ""]
    let possiblePos = [(-0.2, 0.2, -1.0), (0.0, 0.2, -1.0), (0.2, 0.2, -1.0),
                       (-0.2, 0.0, -1.0), (0.0, 0.0, -1.0), (0.2, 0.0, -1.0),
                       (-0.2, -0.2, -1.0), (0.0, -0.2, -1.0), (0.2, -0.2, -1.0)]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBoard()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        configureLighting()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
            let translation = hitTestResultWithFeaturePoints.worldTransform.translation
            addBox(x: translation.x, y: translation.y, z: translation.z)
        }
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func addBoard() {
        guard let boardScene = SCNScene(named: "board.dae") else {return}
        let boardNode = SCNNode()
        for childNode in boardScene.rootNode.childNodes {
            boardNode.addChildNode(childNode)
        }
        boardNode.position = SCNVector3(0, 0, -1)
        boardNode.scale = SCNVector3(0.1, 0.1, 0.1)
        boardNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        sceneView.scene.rootNode.addChildNode(boardNode)
    }
    
    func addBox(x: Float, y: Float, z: Float) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        
        let posIdx = closestPos(raw: SCNVector3(x, y, z))
        if board[posIdx] == "" {
            let pos = possiblePos[posIdx]
            boxNode.position = SCNVector3(pos.0, pos.1, pos.2)
            board[posIdx] = "X"
            sceneView.scene.rootNode.addChildNode(boxNode)
            
            let oPosIdx = getBestMove(board: board)
            if oPosIdx >= 0 {
                board[oPosIdx] = "O"
                let oPos = possiblePos[oPosIdx]
                addSphere(x: oPos.0, y: oPos.1, z: oPos.2)
            }
        }
        
        if XWon(board: board) || OWon(board: board) || boardFull(board: board) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                for node in self.sceneView.scene.rootNode.childNodes {
                    node.removeFromParentNode()
                }
                self.addBoard()
                self.board = ["", "", "",
                         "", "", "",
                         "", "", ""]
            }
        }
    }
    
    func addSphere(x: Double, y: Double, z: Double) {
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
    }
    
    func closestPos(raw: SCNVector3) -> Int {
        var minDist = 100.0
        var closestPos = -1
        for i in 0..<possiblePos.count {
            let pos = possiblePos[i]
            let xDist = pos.0 - Double(raw.x)
            let yDist = pos.1 - Double(raw.y)
            if xDist * xDist + yDist * yDist < minDist{
                minDist = xDist * xDist + yDist * yDist
                closestPos = i
            }
        }
        return closestPos
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

