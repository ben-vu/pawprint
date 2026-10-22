//
//  DogProfileUITests.swift
//  PawprintUITests
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Walks the real app: onboarding if needed, then opens the dog profile
//  sheet from Home, edits a field and saves. Catches hangs and crashes
//  that unit tests cannot see.
//

import XCTest

final class DogProfileUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOpenEditAndSaveDogProfile() throws {
        let app = XCUIApplication()
        app.launch()

        // First run only: get through onboarding.
        let getStarted = app.buttons["Get started"]
        if getStarted.waitForExistence(timeout: 8) {
            getStarted.tap()
            let name = app.textFields["Name"]
            XCTAssertTrue(name.waitForExistence(timeout: 3))
            name.tap()
            name.typeText("Bella")
            let weight = app.textFields["Weight (kg)"]
            weight.tap()
            weight.typeText("18")
            app.buttons["Save profile"].tap()
            XCTAssertTrue(app.buttons["Let's go"].waitForExistence(timeout: 3))
            app.buttons["Let's go"].tap()
        }

        // Home → profile sheet
        let avatar = app.buttons["Dog profile"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 8), "Home did not appear")
        avatar.tap()
        let editProfile = app.buttons["Edit profile"]
        XCTAssertTrue(editProfile.waitForExistence(timeout: 3), "Dog menu did not open")
        editProfile.tap()

        let title = app.navigationBars["Dog profile"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Profile sheet did not open")

        // Edit the breed and save
        let breed = app.textFields["Breed"]
        XCTAssertTrue(breed.waitForExistence(timeout: 3))
        breed.tap()
        breed.typeText(" x")

        // Replace whatever weight is stored with a valid one, so Save is allowed
        let weight = app.textFields["Weight (kg)"]
        weight.tap()
        weight.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) { app.menuItems["Select All"].tap() }
        weight.typeText("18")
        app.navigationBars["Dog profile"].buttons["Save"].tap()

        // Sheet should close and Home should be back
        XCTAssertTrue(avatar.waitForExistence(timeout: 5), "Sheet did not dismiss after Save")
        XCTAssertFalse(title.exists)
    }

    @MainActor
    func testAddAnotherDogFromTheSwitcher() throws {
        let app = XCUIApplication()
        app.launch()

        let avatar = app.buttons["Dog profile"]
        guard avatar.waitForExistence(timeout: 8) else {
            throw XCTSkip("Finish onboarding first, then run this test.")
        }
        avatar.tap()
        let addDog = app.buttons["Add another dog"]
        XCTAssertTrue(addDog.waitForExistence(timeout: 3))
        addDog.tap()

        let name = app.textFields["Name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText("Milo \(Int.random(in: 100...999))")
        let weight = app.textFields["Weight (kg)"]
        weight.tap()
        weight.typeText("9")
        app.navigationBars["Add another dog"].buttons["Save"].tap()

        XCTAssertTrue(avatar.waitForExistence(timeout: 5), "Sheet did not close after saving the new dog")
    }
}
