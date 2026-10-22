//
//  TipLibrary.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  The beginner guides that ship with Pawprint. Writing the content as plain
//  Swift values keeps it version controlled, reviewable in pull requests and
//  available offline from the first launch. SeedTipsUseCase copies it into
//  SwiftData and keeps each tip's bookmark state when the text is updated.
//
//  The guidance is general information for healthy dogs. Every guide ends with
//  a reminder to check specifics with a vet.
//

import Foundation

nonisolated enum TipLibrary {

    /// Every bundled guide, in the order they are shown inside each category.
    static let all: [TipContent] = [
        TipContent(
            contentID: "first-week-with-a-new-dog",
            title: "Your first week with a new dog",
            category: .gettingStarted,
            summary: "Bringing a dog home is exciting for you and overwhelming for them. Here is how to keep the first seven days calm and predictable.",
            keyPoints: [
                "Give your dog a quiet, comfortable spot of their own",
                "Keep feeding, walking and toilet times the same each day",
                "Introduce family and friends slowly, a few at a time",
                "Book a vet check-up within the first week",
                "Expect a few accidents and some unsettled nights",
            ],
            body: """
            Your dog has just left everything familiar behind, whether that was a breeder, a shelter or a foster home. For the first few days they are working out who you are, where things are and what happens when. Set up a bed or crate in a quiet corner, away from foot traffic, and let them retreat there whenever they like.

            Routine is the kindest thing you can give a new dog. Feed at the same times, take them out to toilet at regular intervals and keep walks and play predictable. Dogs relax when they can guess what comes next. Resist the urge to invite everyone over straight away; a few calm introductions spread over the first couple of weeks are much easier for them to cope with.

            Accidents, whining at night and chewing are all normal while your dog settles in. Stay patient and consistent. Book a vet check-up in the first week so your vet can check their health, talk through vaccinations, parasite control and microchipping, and answer any questions you have.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "dog-proofing-your-home",
            title: "Dog-proofing your home",
            category: .gettingStarted,
            summary: "Dogs explore with their mouths. A quick walk around your home at dog height can prevent most first-month emergencies.",
            keyPoints: [
                "Tidy away cables, shoes, socks and small objects",
                "Keep bins, medicines, cleaning products and chocolate out of reach",
                "Check fences and gates for gaps, and secure pool areas",
                "Find out which garden plants are unsafe for dogs",
                "Set up a safe space where your dog can rest undisturbed",
            ],
            body: """
            Get down on your hands and knees and look around. Anything a dog can reach, they may chew or swallow: electrical cords, remote controls, shoes, children's toys and hair ties. Move these out of reach or behind a baby gate, and give your dog plenty of chew toys that are fine for them to destroy.

            Keep kitchen and laundry hazards out of reach as well. Bins, human medicines, cleaning products, chocolate, grapes and sugar-free products containing xylitol can all make a dog seriously ill. Latching cupboards and using lidded bins is a small effort that prevents a lot of worry.

            Outdoors, walk the fence line and look for gaps, loose palings and gates that do not latch. Curious dogs and puppies are surprisingly good at escaping. Some common garden plants, such as sago palms and certain bulbs, are poisonous to dogs, so check any plant you are unsure about with your vet. Always supervise dogs around pools.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "new-dog-shopping-list",
            title: "The new dog shopping list",
            category: .gettingStarted,
            summary: "You do not need to buy everything at once. These are the essentials for the first week, plus the paperwork that is easy to forget.",
            keyPoints: [
                "A collar or harness with an ID tag, and a standard lead",
                "Food and water bowls, and the food your dog is already eating",
                "A comfortable bed or crate",
                "Chew toys, poo bags and a brush suited to the coat",
                "Microchip details and local council registration",
            ],
            body: """
            Start with the basics: a well-fitting collar or harness with an ID tag showing your phone number, a standard fixed-length lead, two bowls, a bed and a few chew toys. Ask the breeder or shelter what your dog has been eating and buy the same food to begin with, because changing food suddenly often upsets their stomach.

            A crate or playpen can give your dog a safe den and help with toilet training and settling. Choose one big enough for them to stand up, turn around and lie down in. Add poo bags and a brush that suits their coat and you are set for the first week.

            Do not forget the paperwork. In New South Wales, dogs must be microchipped and registered with the local council, and the rules differ in other states and territories. Check the requirements where you live and keep your contact details on the microchip registry up to date.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "reading-dog-body-language",
            title: "Reading your dog's body language",
            category: .gettingStarted,
            summary: "Dogs talk with their whole body. Learning a few signals helps you spot stress early and know when to give your dog space.",
            keyPoints: [
                "A wagging tail does not always mean a happy dog",
                "Yawning, lip licking and turning away can signal stress",
                "A play bow, with front end down and back end up, means let's play",
                "A stiff body, hard stare or showing teeth means back off",
                "When in doubt, calmly give your dog more space",
            ],
            body: """
            People often assume a wagging tail means a happy dog, but a wag only tells you the dog is aroused. Look at the whole picture: a loose, wiggly body and relaxed face usually mean friendly, while a stiff body, a high tail and a fixed stare mean the dog is tense.

            Early signs of stress are easy to miss. Watch for lip licking, yawning when they are not tired, turning their head away, showing the whites of their eyes, a tucked tail or ears pinned back. If you see these, calmly move your dog away from whatever is bothering them rather than pushing them to cope.

            Never punish growling. A growl is your dog's way of saying they are uncomfortable, and punishing it can teach them to skip the warning and go straight to biting. Thank them for the warning, give them space and work out what caused it. A trainer or your vet can help if it keeps happening.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "how-much-and-how-often-to-feed",
            title: "How much and how often to feed",
            category: .feeding,
            summary: "Portion size, meal times and the right body shape: the basics of feeding your dog well.",
            keyPoints: [
                "Use the feeding guide on the food packet as a starting point",
                "Puppies usually eat three to four small meals a day, and most adult dogs do well on two",
                "Measure portions instead of guessing",
                "You should be able to feel, but not see, your dog's ribs",
                "Fresh water should always be available",
            ],
            body: """
            Every dog food packet has a feeding guide based on your dog's weight. Use it as a starting point, measure the portion with a scoop or kitchen scales, and adjust based on how your dog looks and feels. Very active dogs may need a little more and couch-loving dogs a little less.

            Young puppies have small stomachs and usually do best with three to four small meals a day, moving to two meals as they grow. Your vet will tell you when to make the change. Most adult dogs do well on two meals a day, which also gives you a predictable rhythm for toilet breaks.

            A simple health check is the rib test. You should be able to feel your dog's ribs under a thin layer of fat without pressing hard. If you cannot, they may be carrying extra weight, and if the ribs are clearly visible they may be underweight. Treats count towards daily food, so keep them small, and ask your vet to help you work out a healthy weight.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "foods-dogs-cannot-eat",
            title: "Foods dogs should never eat",
            category: .feeding,
            summary: "Some everyday human foods are poisonous to dogs. Learn the common ones and keep them out of reach.",
            keyPoints: [
                "Chocolate, grapes, sultanas and raisins",
                "Onions, garlic and chives",
                "Xylitol, a sweetener found in some gum, lollies and peanut butter",
                "Macadamia nuts, alcohol and cooked bones",
                "If your dog eats something dangerous, call your vet straight away",
            ],
            body: """
            Chocolate, grapes, sultanas and raisins are among the most common causes of poisoning in dogs. Even a small amount of grapes or raisins can be harmful to some dogs, and the darker the chocolate, the more dangerous it is. Onions, garlic and chives can damage a dog's red blood cells, and macadamia nuts can cause weakness and vomiting.

            Xylitol is a sugar-free sweetener found in some chewing gum, lollies, baked goods and even some peanut butters. It can cause a dangerous drop in blood sugar and liver damage in dogs. Always check labels before sharing any human food. Cooked bones can splinter and cause injuries, and alcohol is never safe for dogs.

            If you think your dog has eaten something harmful, do not wait for symptoms. Call your vet or an emergency animal hospital straight away and tell them what was eaten, how much and when. Keeping the packet to show them helps.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "switching-food-and-fussy-eaters",
            title: "Switching food and fussy eaters",
            category: .feeding,
            summary: "How to change your dog's food without tummy upsets, and what to do when they turn their nose up at dinner.",
            keyPoints: [
                "Switch foods gradually over seven to ten days",
                "Offer meals at set times and pick up the bowl after 15 to 20 minutes",
                "Avoid adding tasty extras every time to tempt them",
                "A dog who refuses food for more than a day needs a vet check",
                "Puppies and small dogs should see a vet sooner if they stop eating",
            ],
            body: """
            When changing foods, mix a little of the new food into the old and increase the amount of the new food every couple of days over seven to ten days. This gives your dog's gut time to adjust and helps avoid vomiting or loose stools.

            Healthy dogs are rarely truly fussy. If your dog skips a meal, stick to your routine: offer the food for fifteen to twenty minutes, then take it away until the next meal. Topping meals with tasty extras every time teaches dogs that holding out gets them a better dinner.

            A sudden change in appetite can be a sign of illness, though. If your dog refuses food for more than a day, or seems unwell, call your vet. Puppies and very small dogs can become unwell quickly when they do not eat, so get advice sooner.
            """,
            readingMinutes: 2
        ),
        TipContent(
            contentID: "how-much-exercise-does-your-dog-need",
            title: "How much exercise does your dog need?",
            category: .exercise,
            summary: "Every dog needs both physical and mental exercise. Here is how to work out the right amount for yours.",
            keyPoints: [
                "Needs vary a lot by breed, age and health",
                "Most healthy adult dogs benefit from 30 minutes to 2 hours of activity a day",
                "Puppies need short, frequent bursts, not long runs",
                "Sniffing and games count as exercise for the brain",
                "Ask your vet before starting a big new routine",
            ],
            body: """
            A working breed such as a border collie may need far more activity than a French bulldog or a senior dog. As a general guide, most healthy adult dogs do well with somewhere between thirty minutes and two hours a day, split over walks, play and training. Breed, age and health all matter, so ask your vet what is right for your dog.

            Puppies are different. Their bones and joints are still growing, so avoid long runs, repeated jumping and forced exercise. A common rule of thumb is about five minutes of structured exercise per month of age, up to twice a day, plus plenty of free play and rest. Check with your vet about your own puppy.

            Mental exercise tires a dog out just as well as physical exercise. Sniffing on walks, puzzle feeders and short training games all give their brain a workout. A bored dog is often a destructive dog, so if yours is chewing or barking at home, they may need more of both.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "walking-basics",
            title: "Walking basics: lead, heat and manners",
            category: .exercise,
            summary: "A few simple habits make every walk safer and more enjoyable for you and your dog.",
            keyPoints: [
                "Walk in the cooler parts of the day in summer",
                "Test the pavement with the back of your hand for five seconds",
                "Use a well-fitted harness or collar and a standard lead",
                "Carry water and poo bags",
                "Only let your dog off the lead in designated off-leash areas",
            ],
            body: """
            A well-fitting harness or collar and a fixed-length lead give you the best control. Be careful with retractable leads, as they encourage pulling and can cause injuries to dogs and people. Carry water for your dog and bags to pick up after them; many councils fine owners who do not.

            Hot ground can burn paws quickly. Place the back of your hand on the pavement for five seconds: if it is too hot for you, it is too hot for your dog. In summer, walk early in the morning or in the evening, stick to grass or shade and watch for signs of overheating.

            Keep your dog on a lead in public unless you are in a designated off-leash area, and make sure they come reliably when called before you try off-leash time. Check your local council's rules, because off-leash areas and times differ between councils.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "rainy-day-games",
            title: "Rainy-day games and brain workouts",
            category: .exercise,
            summary: "When the weather is bad or you are short on time, these simple games keep your dog's brain busy.",
            keyPoints: [
                "Hide treats around the house for a sniffing game",
                "Feed meals from a puzzle feeder or snuffle mat",
                "Practise a few five-minute training sessions",
                "Rotate toys so they stay interesting",
                "Play tug and fetch with clear start and stop cues",
            ],
            body: """
            Dogs have an incredible sense of smell, and using it is tiring in a good way. Hide a few treats around a room, or scatter their dry food on a snuffle mat or in the grass, and let them hunt. It is a great option for rainy days, hot days or recovery after an injury.

            Puzzle feeders and food-dispensing toys turn mealtime into a game. Short training sessions work too: five minutes of sit, down and touch uses plenty of mental energy. Rotate toys so that old favourites feel new again.

            Games such as tug and fetch are great, as long as you teach your dog to start when you say and let go on cue. Keep play friendly, stop before your dog gets over-excited and finish with something calm.
            """,
            readingMinutes: 2
        ),
        TipContent(
            contentID: "positive-reinforcement-101",
            title: "Positive reinforcement 101",
            category: .training,
            summary: "Rewarding what you like is the simplest and most effective way to train a dog. Here is how it works.",
            keyPoints: [
                "Reward the behaviour you want within a second or two",
                "Use small, tasty treats, praise or play as rewards",
                "Keep training sessions short, around five minutes",
                "Be consistent: everyone in the house uses the same cues",
                "Do not shout at, hit or punish your dog",
            ],
            body: """
            Dogs repeat behaviours that pay off. When your dog does something you like, such as sitting calmly or looking at you, mark it with a cheerful word like yes and give a treat straight away. Timing matters: the reward needs to arrive within a second or two, or your dog will not link it with what they did.

            Short, fun sessions of about five minutes, a few times a day, work better than one long session. Train somewhere quiet first, then slowly add distractions. Use a small, soft treat so your dog can eat it quickly and keep their attention on you.

            Consistency is the secret. Decide on your cues and house rules, such as whether the dog is allowed on the couch, and make sure everyone follows them. Rather than punishing unwanted behaviour, manage the situation and reward the alternative you want. Punishment can damage trust and cause fear.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "toilet-training-a-puppy",
            title: "Toilet training a puppy",
            category: .training,
            summary: "Most puppies can learn to toilet outside with a consistent routine, patience and lots of praise.",
            keyPoints: [
                "Take your puppy out after waking, eating, drinking and playing",
                "Go to the same spot and wait calmly",
                "Praise and reward straight after they finish outside",
                "Never punish accidents; clean up with a pet-safe enzymatic cleaner",
                "Expect progress to take weeks to months",
            ],
            body: """
            Young puppies cannot hold on for long, so take them out often, at least every one to two hours at first, and always after waking up, eating, drinking and playing. Take them to the same spot, stay calm and wait. When they finish, praise warmly and give a treat straight away, while they are still outside.

            Watch for signs they need to go, such as sniffing, circling or heading for the door. When you cannot supervise, use a crate or playpen, since most puppies do not like to soil where they sleep. Overnight, expect a toilet trip or two while they are very young.

            Accidents will happen. Do not punish your puppy, as this can teach them to hide when they need to go. Calmly clean up with an enzymatic cleaner to remove the smell that draws them back, and try to catch the next one in time. Most puppies become reliable within a few months, but it varies, so talk to your vet if progress stalls.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "sit-come-and-leave-it",
            title: "Teaching sit, come and leave it",
            category: .training,
            summary: "Three simple skills that make daily life easier and safer for you and your dog.",
            keyPoints: [
                "Sit: lure with a treat over the nose and reward the moment their bottom touches the floor",
                "Come: make coming to you the best thing ever, never a punishment",
                "Leave it: reward your dog for ignoring something they want",
                "Practise in short sessions, starting somewhere quiet",
                "Add distance and distractions only once your dog is succeeding",
            ],
            body: """
            To teach sit, hold a treat close to your dog's nose and slowly move it up and back over their head. As their head goes up, their bottom goes down. The moment it touches the floor, say yes and give the treat. After a few repetitions, add the word sit just before you lure.

            For coming when called, start indoors. Say your dog's name and come in a happy voice, and reward generously when they reach you. Never call your dog to scold them or to end the fun, or they will learn that coming to you is bad news. Practise in more distracting places gradually, and keep your dog on a lead until their recall is reliable.

            Leave it could save your dog's life. Hold a treat in a closed fist and let your dog sniff and nibble at it. The moment they pull away, even briefly, reward them with a different treat from your other hand. Gradually progress to leaving items on the floor.
            """,
            readingMinutes: 4
        ),
        TipContent(
            contentID: "socialising-your-puppy",
            title: "Socialising your puppy",
            category: .training,
            summary: "The first sixteen weeks are a special window for learning that the world is safe. Here is how to use it well.",
            keyPoints: [
                "Puppies are most open to new experiences up to around 14 to 16 weeks",
                "Introduce new sights, sounds, surfaces and friendly people gently",
                "Keep every experience positive and let your puppy go at their own pace",
                "Ask your vet when your puppy can safely meet other dogs and visit public places",
                "Socialisation continues beyond puppyhood",
            ],
            body: """
            Between roughly three and sixteen weeks of age, puppies learn quickly what is normal and what is scary. Positive experiences during this window with different people, surfaces, sounds, vehicles and calm, vaccinated dogs help puppies grow into confident adults. Aim for variety rather than overwhelm.

            Let your puppy approach new things at their own pace, and pair them with treats and calm encouragement. If they seem scared, give them space and try again from further away. Forcing them to face a fear can make it worse.

            Vaccinations and socialisation need to be balanced carefully. Your vet will tell you when your puppy is safe to meet other dogs and visit public places, and can recommend puppy classes run in a clean, safe environment. In the meantime you can carry your puppy to see the world and invite healthy, vaccinated dogs to your home.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "learning-to-be-alone",
            title: "Learning to be home alone",
            category: .training,
            summary: "Being left alone is a skill dogs have to learn. Build it up slowly and watch for signs of distress.",
            keyPoints: [
                "Start with very short absences and build up slowly",
                "Give your dog exercise and a toilet break before you leave",
                "Leave a safe chew or food toy",
                "Keep arrivals and departures low-key",
                "Talk to your vet or a trainer if your dog panics, howls or damages things when alone",
            ],
            body: """
            Dogs are social animals, and being alone can be stressful at first. Start by leaving your dog for a few seconds in another room, then minutes, then slowly longer. Return before they become upset, so they learn that you always come back.

            Before you go, give them a walk and a toilet break, then leave a safe chew or a food-filled toy. Keep goodbyes and hellos calm, because big emotional greetings can make being alone feel like an even bigger change.

            Some dogs find being alone truly distressing. Signs include constant barking or howling, destructive behaviour near doors or windows, toileting in the house when otherwise reliable, or heavy drooling and panting. This is anxiety, not naughtiness. Talk with your vet or a qualified trainer about a plan, and do not punish.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "brushing-and-coat-care",
            title: "Brushing and coat care",
            category: .grooming,
            summary: "Regular brushing keeps the coat healthy, cuts down on shedding and lets you spot skin problems early.",
            keyPoints: [
                "Short coats: brush about once a week",
                "Long or double coats: brush several times a week",
                "Curly or woolly coats may need daily brushing to prevent matting",
                "Use a brush that suits your dog's coat",
                "Check skin for lumps, scratches, fleas and ticks while you brush",
            ],
            body: """
            How often you brush depends on the coat. Short-haired dogs usually need a weekly brush to remove loose hair. Long-haired and double-coated dogs benefit from brushing several times a week, and curly or woolly coats, like those of poodles and many crossbreeds, can mat quickly and may need brushing daily.

            Make brushing a calm, rewarding routine. Start with short sessions, give treats and work gently, especially around the ears, armpits and tail where knots form. Ask a groomer or your vet which brush suits your dog's coat.

            Brushing is also a chance to give your dog a mini health check. Run your hands over their body and look for lumps, scratches, red or sore skin, fleas and ticks. Tell your vet about anything new.
            """,
            readingMinutes: 2
        ),
        TipContent(
            contentID: "bath-time-basics",
            title: "Bath time basics",
            category: .grooming,
            summary: "Most dogs only need a bath every month or two. Here is how to make it stress-free.",
            keyPoints: [
                "Bathe about every four to eight weeks, or when your dog is dirty or smelly",
                "Use a shampoo made for dogs, never human products",
                "Use lukewarm water and keep it out of ears and eyes",
                "Rinse thoroughly, as leftover shampoo irritates skin",
                "Dry well, especially skin folds and under the ears",
            ],
            body: """
            Bathing too often can dry out your dog's skin, so most dogs only need a bath every four to eight weeks, or when they have rolled in something unpleasant. Brush out any tangles before the bath, as water tightens knots, and place a non-slip mat in the bath or tub.

            Use lukewarm water and a shampoo made for dogs, since human shampoo can irritate their skin. Work from the neck down, avoid the eyes and ears, and rinse until the water runs clear. Leftover shampoo is a common cause of itchy skin.

            Dry your dog well with a towel, particularly skin folds and ears, where damp can lead to infections. Reward calm behaviour with treats. If your dog hates baths, a professional or mobile groomer can help.
            """,
            readingMinutes: 2
        ),
        TipContent(
            contentID: "nails-ears-and-teeth",
            title: "Nails, ears and teeth",
            category: .grooming,
            summary: "Short nails, clean ears and healthy teeth need just a few minutes of care each week.",
            keyPoints: [
                "Trim nails when you can hear them clicking on hard floors",
                "Check ears weekly for redness, smell or discharge",
                "Brush teeth with dog toothpaste, ideally daily",
                "Never use human toothpaste",
                "Ask your vet or groomer to show you how if you are unsure",
            ],
            body: """
            Nails that are too long can be uncomfortable and change how your dog walks. If you hear clicking on hard floors, it is time for a trim. Take off small amounts at a time and avoid the quick, the pink core that contains blood vessels. If you are nervous, ask your vet or groomer to show you, or have them do it.

            Check your dog's ears each week. Healthy ears look clean and do not smell. Redness, a bad smell, discharge, scratching or head shaking suggest a problem, so see your vet rather than putting anything into the ear yourself.

            Dental disease is very common in dogs. Brush with a soft toothbrush and a toothpaste made for dogs, ideally every day, and introduce it slowly with lots of praise. Human toothpaste is not safe for dogs to swallow, so never use it. Ask your vet about dental chews and regular dental check-ups.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "vaccinations-and-vet-check-ups",
            title: "Vaccinations and vet check-ups",
            category: .health,
            summary: "Vaccinations protect your dog from serious diseases. Here is what a typical puppy schedule looks like and why regular check-ups matter.",
            keyPoints: [
                "Puppies usually have a series of vaccinations in their first four months",
                "A common schedule is around 6 to 8, 10 to 12 and 14 to 16 weeks",
                "Adult dogs need boosters and a yearly health check",
                "Your vet will recommend the vaccines that suit your dog and area",
                "Record dates in the Health tab so you never miss a booster",
            ],
            body: """
            Vaccines protect against serious diseases such as parvovirus, distemper and hepatitis. Puppies usually have a series of vaccinations, commonly around six to eight, ten to twelve and fourteen to sixteen weeks, because antibodies from their mother can interfere with early doses. Your vet will set the exact schedule for your puppy.

            Boosters keep protection up as your dog grows. Depending on where you live and your dog's lifestyle, your vet may also recommend vaccination against kennel cough. Do not guess: ask your vet which vaccines your dog needs and when the next one is due.

            A yearly check-up is the best way to catch problems early. Your vet will weigh your dog, check their teeth, heart, skin and joints, and talk about parasite control, diet and any concerns. Use the Health tab to record visits and due dates so nothing slips.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "fleas-ticks-and-worms",
            title: "Fleas, ticks and worms",
            category: .health,
            summary: "Parasite prevention is a year-round job. Here are the basics for fleas, ticks, heartworm and intestinal worms.",
            keyPoints: [
                "Use a vet-recommended product for your dog's weight and follow the label",
                "Fleas, intestinal worms and heartworm each need regular prevention",
                "In tick areas, check your dog every day, even if they are on prevention",
                "Puppies need worming more often than adult dogs",
                "Never use a product made for a different species or weight",
            ],
            body: """
            Fleas are more than an itch: they can cause skin allergies and carry tapeworm. Flea products come as chews, spot-on treatments or collars, and each has its own schedule, from monthly to every few months. Choose one your vet recommends for your dog's weight and follow the label exactly. Treat all pets in the house and wash bedding.

            Heartworm is spread by mosquitoes and can be fatal, and prevention is recommended for dogs across much of Australia. Intestinal worming is also regular: puppies are commonly wormed every two weeks until twelve weeks, then monthly until six months, then about every three months, but your vet will advise the right plan for your dog.

            On the east coast, including Sydney, paralysis ticks are a serious danger, especially in the warmer months. Prevention products help but are not perfect, so run your fingers over your dog's whole body every day, including between the toes, under the collar and inside the ears. If you find a tick, or your dog has wobbly back legs, vomiting or laboured breathing, see a vet immediately. Set reminders for all of these in the Health tab.
            """,
            readingMinutes: 4
        ),
        TipContent(
            contentID: "when-to-call-the-vet",
            title: "When to call the vet",
            category: .health,
            summary: "Dogs hide illness well. Know the warning signs that mean call today, and the ones that mean go now.",
            keyPoints: [
                "Go now: trouble breathing, collapse, seizures, pale gums or a swollen belly with unproductive retching",
                "Go now if your dog has eaten something toxic or may have heat stroke",
                "Call the same day for repeated vomiting or diarrhoea, blood in stool, or a limp that does not ease",
                "Call if your dog stops eating or drinking, or is unusually quiet",
                "Trust your instincts: you know your dog best",
            ],
            body: """
            Some signs are emergencies and mean you should get to a vet or emergency animal hospital immediately: difficulty breathing, collapse, seizures, pale or blue gums, a swollen belly with unproductive retching, suspected poisoning, signs of heat stroke or any serious accident. Call ahead so they can prepare for you.

            Other signs need a call to your vet the same day: repeated vomiting or diarrhoea, blood in the stool or urine, straining to toilet, limping or crying out in pain, red or swollen eyes, or not eating or drinking. Puppies, older dogs and small dogs can get worse quickly.

            You know your dog's normal energy, appetite and habits better than anyone. If something seems off, it is always fine to call your vet for advice. Save your vet's number and the nearest 24-hour emergency clinic in your phone before you need them.
            """,
            readingMinutes: 3
        ),
        TipContent(
            contentID: "keeping-your-dog-cool",
            title: "Keeping your dog cool in summer",
            category: .health,
            summary: "Dogs overheat much faster than people. A few habits keep them safe when the temperature climbs.",
            keyPoints: [
                "Never leave your dog in a parked car, even briefly",
                "Provide shade and plenty of fresh water",
                "Walk in the early morning or evening",
                "Take extra care with flat-faced breeds, puppies, seniors and overweight dogs",
                "Heavy panting, drooling, wobbliness or collapse can mean heat stroke: cool them slowly and see a vet immediately",
            ],
            body: """
            Dogs cannot sweat like we do, so they cool down mostly by panting, which works poorly in hot, humid weather. Always provide shade and cool, fresh water, and avoid exercise during the hottest part of the day. Cars heat up within minutes, so never leave your dog inside one, even with the windows down.

            Some dogs are at higher risk: flat-faced breeds such as pugs and bulldogs, puppies, older dogs, dogs with thick coats and overweight dogs. Keep them indoors with a fan or air conditioning on very hot days.

            Signs of heat stroke include heavy panting, thick drool, bright red gums, vomiting, wobbliness or collapse. Move your dog into shade, wet them with cool (not ice-cold) water, offer small sips and get to a vet straight away, as heat stroke can be life-threatening.
            """,
            readingMinutes: 2
        ),
    ]
}
