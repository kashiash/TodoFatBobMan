# Todo by FatBobMan
# translate by chatgpt



Aplikacja Todo - CORE DATA jako HARDCORE ;) 

tlumaczenie  https://itnext.io/swiftui-and-core-data-data-fetching-c0c7f62aaf53 i artykułów powiązanych





Używam Core Data od kilku lat. Chociaż nie mogę twierdzić, że całkowicie opanowałem ten temat, jestem w nim biegły i rzadko popełniam podstawowe błędy. Obecnie moim głównym wyzwaniem i kierunkiem badań jest integracja Core Data z popularnymi architekturami aplikacji i sprawienie, by działał on bardziej płynnie w środowiskach takich jak SwiftUI, TCA, Unit Tests i Preview. W kolejnych kilku artykułach podzielę się niektórymi z moich pomysłów, spostrzeżeń, doświadczeń i praktyk w tym obszarze z ostatnich sześciu miesięcy. Mam również nadzieję na więcej dyskusji z przyjaciółmi, którzy mają podobne obawy.

### Gotowy na wyzwanie?

Core Data to framework o długiej historii. Jeśli zaczniemy liczyć od pierwszej integracji frameworku Core Data w MacOS X Tigger, wydanym przez Apple w 2005 roku, Core Data istnieje nieco ponad dekadę. Jednak biorąc pod uwagę, że wiele z jego projektowania było dziedziczone po frameworku EOF (Enterprise Objects Framework), wprowadzonym przez Next w 1994 roku, jego główne założenia filozofii projektowej istnieją już prawie trzydzieści lat. W kodzie frameworku Core Data, historyczny prefiks 'NS' jest nadal powszechnie używany.

W przeciwieństwie do obecnie dominującego użycia Core Data, EOF został zintegrowany z serwerem aplikacji WebObjects. W pierwszych dniach e-commerce, wiele dużych firm, takich jak BBC, Dell, Disney, GE i Merrill Lynch, zostało przyciągniętych przez jego zastosowanie. Do niedawnych lat, WebObjects nadal dostarczał energię dla Apple Store i iTunes Store firmy Apple. Dlatego nie jest trudno zrozumieć, dlaczego Core Data, w przeciwieństwie do innych popularnych mobilnych rozwiązań związanych z utrzymaniem danych, nie dąży do nadmiernej efektywności dostępu do danych, a stabilność jest jego najważniejszym celem. Od dawna jest to konsensus wśród wielu deweloperów.

Być może dlatego, że filozofia projektowa była bardzo zaawansowana, a implementacja już doskonała, albo może z powodu niższych inwestycji Apple w ostatnich latach, Core Data dodał następujące nowe funkcje w ostatnich pięciu czy sześciu latach, nie wymagając zbyt wielu zmian w kodzie jądrowym:

```
NSPersistentContainer
```

Oficjalna implementacja, która opakowuje koordynatora, trwały magazyn i kontekst zarządzanego obiektu. Prawie nie ma potrzeby dostosowywania żadnego kodu rdzeniowego.

```
Śledzenie historii trwałości
```

To jest największa ostatnio zmiana. Do trwałego magazynu dodano więcej operacji wyzwalających, a koordynator otrzymał API, które reaguje na zmiany.

```
Operacje wsadowe na danych
```

Pozwala programistom ominąć kontekst i wykonywać operacje wsadowe bezpośrednio na trwałym magazynie z poziomu koordynatora.

    Core Data z CloudKit

Prawie nie ma potrzeby dostosowywać kodu rdzeniowego, dodano NSPersistentCloudKitContainer i dołączono moduł do synchronizacji sieciowej do koordynatora.

    Wsparcie dla async/await

Dostarcza nową implementację metody perform.

Chociaż ostatnio wśród deweloperów krążą plotki (lub fantazje), że Apple wprowadzi całkowicie nowy framework mający zastąpić Core Data, uważne spojrzenie na historię i kod Core Data pokazuje, że prawdopodobieństwo pojawienia się nowego frameworku jest bardzo niskie. Z jednej strony, jego doskonała architektura projektowa nadal może spełniać potrzeby dodawania nowych funkcji w przyszłości; z drugiej strony, zastąpienie frameworku o tak długiej historii i stabilnej reputacji wymaga dużo odwagi. Dlatego deweloperzy mogą kontynuować korzystanie z tego frameworku przez długi czas w przyszłości.

Ścisłe rzecz biorąc, pomijając wadę trudności w nauce i opanowaniu, w idealnym środowisku, Core Data jest całkiem doskonały pod względem stabilności, efektywności rozwoju, skalowalności itp. (niestabilna synchronizacja sieciowa nie jest problemem Core Data). Nadal jest to najlepszy wybór do zarządzania grafami obiektów, cyklami życia obiektów i trwałością danych w ekosystemie Apple.

Jednak nie oznacza to, że Core Data może w pełni dostosować się do dzisiejszego środowiska deweloperskiego. Chociaż nadal ma ono przełomowy umysł i solidne jądro, jego wygląd jest zbyt przestarzały i trudno dopasować go do nowych frameworków i nowych procesów rozwoju. Jeśli moglibyśmy stworzyć dla niego nowy wygląd, być może mógłby odzyskać młodość i walczyć ponownie przez następną dekadę.



### Twoja Chwała, Moja Udręka

Co ciekawe, większość czynników, które powodują, że Core Data nie integruje się dobrze z nowymi frameworkami i procesami rozwoju, to niektóre z funkcji lub zalet, z których Core Data jest dumny.

#### Kto odpowiada za strukturę danych w Core Data?

Głównym zadaniem Core Data jest zarządzanie grafem obiektów, a utrwalanie danych jest tylko jedną z jego towarzyszących funkcji. W porównaniu do innych frameworków, zdolność Core Data do opisywania i obsługi relacji jest jego główną konkurencyjną zaletą. Być może, aby ułatwić opisywanie skomplikowanej logiki relacji, deweloperzy zwykle muszą tworzyć opisy encji w edytorze modelu danych Xcode przed utworzeniem struktur danych (wspierają bezpośrednią definicję za pomocą kodu, ale ta metoda jest rzadziej używana), a następnie generować odpowiedni kod definicji NSManagedObject automatycznie lub ręcznie. Prowadzi to do następujących problemów:

- Aby utrzymać zgodność z Objective-C (dane wewnętrzne Core Data są nadal implementowane za pomocą Objective-C), deweloperzy mogą używać tylko ograniczonych typów danych do opisywania atrybutów w edytorze modelu danych. To utrudnia deweloperom myślenie i opisywanie nowej struktury danych (odpowiadającej encji Core Data) w najbardziej odpowiednim stylu języka Swift na pierwszy rzut oka, i nieświadomie polegają na zdolności wyrażania się edytora modelu.

- W przypadku korzystania z synchronizacji sieciowej danych (Core Data z CloudKit), zasada dodawania tylko, ale nie zmniejszania lub modyfikowania nazw encji lub atrybutów po uruchomieniu produktu oznacza, że niezależnie od tego, jak nierozsądnie zdefiniowano pierwotne nazwy encji, atrybutów i relacji, deweloperzy mogą je tylko znosić. W miarę jak wersje ciągle się iterują, te niewłaściwe nazwy wypełnią każdą część kodu, sprawiając, że ludzie chcą płakać.
- Trudno jest wejść w stan rozwoju procesu biznesowego na pierwszy rzut oka. Kiedy używane są zarządzane obiekty jako rodzaj opisu danych, pierwszy kod, który deweloperzy często piszą, jest związany ze stosem Core Data. W procesie rozwoju aplikacji, każde dostosowanie definicji danych wymaga przejścia przez warstwy przetwarzania (edytor modelu, odpowiednia definicja NSManagedObject, odpowiedni kod w stosie), poważnie wpływając na efektywność rozwoju.

Podsumowując, kiedy Core Data jest używany w aplikacji, trudno jest deweloperom pozbyć się jego cienia na początkowym etapie rozwoju. Od momentu zaimportowania Core Data ma negatywny wpływ na kreatywność, intuicję i entuzjazm deweloperów.

#### Framework zarządzany "wirusopodobnie"

Mechanizm zarządzania Core Data istnieje od ery EOF. Ten mechanizm pozwala Core Data eksponować dane z podstawowego źródła danych jako zarządzany graf trwałych obiektów (obiekty danych w pamięci), oraz modyfikować i śledzić graf obiektów za pomocą zarządzanych kontekstów. Możliwość ładowania leniwego, którą oferuje mechanizm zarządzania, może pomóc deweloperom zrównoważyć między efektywnością czytania a wykorzystaniem pamięci. Można powiedzieć, że posiadanie mechanizmu zarządzania jest długotrwałą, dumą cechą Core Data.

Jednak mechanizm zarządzania oznacza, że deweloperzy muszą zbudować zgodne środowisko zarządzane przed wykonaniem jakichkolwiek operacji. Operowanie na zarządzanych obiektach wymaga najpierw utworzenia kontekstu zarządzanego obiektu. Warunkiem działania kontekstu jest utworzenie zarządzanego koordynatora i trwałego sklepu.

Oprócz złożoności tworzenia zarządzanego środowiska, stabilność zarządzanego środowiska w niektórych sytuacjach nie jest niezawodna. Faktycznie, zarządzane środowisko Core Data jest obecnie jednym z głównych powodów, dla których podglądy SwiftUI nie działają. Ponadto, przygotowanie i resetowanie zarządzanego środowiska spowolni również szybkość testów jednostkowych, wpływając na chęć deweloperów do pisania testów jednostkowych. W rezultacie, poważnie podważy to entuzjazm deweloperów do przyjęcia modularnego (SPM) rozwoju w swoich aplikacjach.

Jeśli wartość R0 Omicron BA.4/5 wynosi 18,6, to podstawowy wskaźnik reprodukcyjny kodu dotyczącego zarządzanych obiektów w aplikacji z powodu mechanizmu zarządzania wynosi ∞, raz użyjesz, i nie masz sensownej metody, aby sie go pozbyć.

#### Wiązanie Wątków i Sendable

Chociaż zarządzane obiekty Core Data nie są bezpieczne kodzie wielowątkowym, bezpieczne jest rozwijanie na wielu wątkach w Core Data, o ile ściśle przestrzega się konwencji użytkowania (używanie zarządzanych kontekstów tylko do tworzenia zarządzanych obiektów). Chociaż niektórzy deweloperzy uważają, że rozwijanie na wielu wątkach w Core Data jest uciążliwe, niezaprzeczalne jest, że w porównaniu do innych podobnych frameworków, używanie Core Data do rozwoju wielowątkowego zapewnia wysoki poziom stabilności.

Z poprawą Swift 5.5 w zakresie zdolności asynchronicznych i równoległych, deweloperzy niewątpliwie będą używać nowych mechanizmów asynchronicznych lub równoległych w swoim kodzie. Na przykład, Reducer TCA obecnie ewoluuje w kierunku Global Actor (tzn. Reducer nie będzie już działać w głównym wątku). Aby uniknąć problemów z bezpieczeństwem wątków, przestrzeganie protokołu Sendable jest skutecznym środkiem.

Oczywiście, zarządzane obiekty nie mają podstawy do przestrzegania protokołu Sendable. Jak sprawić, że Core Data współpracuje z frameworkami, które korzystają z nowych mechanizmów równoległych, to również nowe wyzwanie stojące przed deweloperami.

#### Moj najbliższy plan w tym artykule

Chociaż jest to trochę chciwe, nadal mam nadzieję, że uda pogodzić się oba cele. Będziemy razem eksplorować przez kilka artykułów, próbując osiągnąć następujące cele:

- Zminimalizować wpływ Core Data na proces definicji danych (szczególnie na wczesnym etapie rozwoju)

- Po przełączeniu źródła danych na Core Data, nie ma potrzeby modyfikowania istniejącego kodu
- W fazach podglądu i testowania jednostkowego, nie daj się już zakłócić zarządzanym środowiskiem, więc możemy łatwo modularizować zarządzanie kodem
- Zachować mechanizm ładowania leniwego Core Data, aby uniknąć nadmiernego zajmowania pamięci
- Zgodny z nowymi mechanizmami współbieżności, aby znaleźć największy wspólny dzielnik Sendable
- Osiągnięcie powyższych celów z najmniejszą ilością kodu i uniknięcie zwiększenia niestabilności systemu

### Aplikacja ToDo

Todo to przykładowa aplikacja przygotowana na potrzeby tej serii artykułów. Takich przykładów w internecie jest sporo. W tym artykule staram się, aby ta prosta aplikacja wykorzystała większej liczby scenariuszy rozwoju SwiftUI + Core Data. Użytkownicy mogą tworzyć zadania do wykonania w Todo i mogą używać Grup Zadań do lepszego zarządzania.

Kod Todo ma następujące cechy:

- Przyjęcie modularnego podejścia do rozwoju, z definicją danych, widokiem i implementacją DB w oddzielnych modułach.
- Z wyjątkiem widoków używanych do konkatenacji (łączenia wielu widoków szczegółowych), wszystkie szczegółowe widoki są odłączone od przepływu danych aplikacji, umożliwiając adaptację do różnych frameworków (czysto napędzane SwiftUI, TCA, lub inne ramy Redux) bez zmian w kodzie.
- Wszystkie widoki można podejrzeć bez użycia żadnego kodu Core Data, a mogą one dynamicznie reagować na dane mock-up.



Co było pierwsze, jako czy kura ?

Core Data prezentuje dane za pomocą zarządzanych obiektów (zdefiniowanych w edytorze modelu danych). To pozwala programistom manipulować danymi w sposób znany bez konieczności rozumienia specyficznej struktury i organizacji trwałych danych. Niestety, zarządzane obiekty nie są bardzo przyjazne dla SwiftUI, które jest głównie oparte na typach wartości. Dlatego wielu programistów konwertuje instancje zarządzanego obiektu na instancje struktury w widoku do łatwiejszej manipulacji.

Dlatego w tradycyjnym wzorcu rozwoju aplikacji Core Data, programiści zazwyczaj muszą wykonać następujące kroki, aby utworzyć widok komórki grupy pokazany powyżej (używając grupy zadań w aplikacji Todo jako przykładu):

- Stwórz encję o nazwie C_Group w edytorze modelu danych Xcode, wraz z dowolnymi powiązanymi encjami, takimi jak C_Task.
- Może być konieczne poprawienie kompatybilności typów zarządzanego obiektu poprzez modyfikację kodu C_Group (lub dodanie obliczeniowych właściwości).
- Zdefiniuj strukturę, która jest łatwa do użycia w środowisku SwiftUI i stwórz metody rozszerzeń dla zarządzanych obiektów, aby osiągnąć konwersję.

Przykład:

```swift
struct TodoGroup {
    var title: String
    var taskCount: Int // Liczba zadań zawartych w bieżącej grupie
}

extension C_Group {
    func convertToGroup() -> TodoGroup {
        .init(title: title ?? "", taskCount: tasks?.count ?? 0)
    }
}

```

Utwórz widok GroupCell.

```swift
struct GroupCellView:View {
    @ObservedObject var group:C_Group
    var body: some View {
        let group = group.convertToGroup()
        HStack {
            Text(group.title)
            Text("\(group.taskCount)")
        }
    }
}
```

Zgodnie z powyższym procesem, nawet bez początkowego modelowania, możemy w pełni zaspokoić potrzeby rozwoju widoku, opierając się wyłącznie na strukturze TodoGroup. W rezultacie sekwencja procesu zmieni się na:

1. Zdefiniuj strukturę TodoGroup
2. Zbuduj widok

W tym momencie widok można uprościć do:

```swift
struct GroupCellView:View {
    let group: TodoGroup
    var body: some View {
        HStack {
            Text(group.title)
            Text("\(group.taskCount)")
        }
    }
}
```

Podczas procesu rozwoju możemy dostosować TodoGroup według potrzeb, nie zastanawiając się zbytnio, jak organizować dane w Core Data lub bazie danych (chociaż programiści nadal potrzebują pewnej podstawowej wiedzy o programowaniu Core Data, aby uniknąć tworzenia całkowicie nierealistycznych formatów danych). Modelowanie i konwersja danych Core Data powinny być wykonane tylko w końcowym etapie (po zakończeniu widoków i innych przetwarzania logicznego).

To pozornie proste przekształcenie - z kury (zarządzany obiekt) do jajka (struktura) do kury (struktura) do jajka (zarządzany obiekt) - całkowicie zakłóci nasz wcześniej przyzwyczajony proces rozwoju.



### Inne zalety zarządzanych obiektów

Używanie struktury do bezpośredniego reprezentowania danych w widoku jest niewątpliwie wygodne, ale nie możemy zignorować innych zalet zarządzanych obiektów. Dla SwiftUI, zarządzane obiekty mają dwie bardzo zauważalne cechy:

1. Opóźnione ładowanie "Lazy loading"

Tak zwane zarządzanie zarządzanymi obiektami odnosi się do faktu, że obiekt jest tworzony i utrzymywany przez zarządzany kontekst. Tylko w razie potrzeby, wymagane dane są ładowane z bazy danych (lub pamięci podręcznej wierszy). W połączeniu z leniwymi kontenerami ładowania SwiftUI (List, LazyStack, LazyGrid), można doskonale zrównoważyć wydajność i zużycie zasobów.

2. Reakcja na zmiany w czasie rzeczywistym

Zarządzane obiekty (NSManagedObject) są zgodne z protokołem ObservableObject i mogą powiadamiać widoki o odświeżenie, gdy nastąpią zmiany danych.

Dlatego, bez względu na wszystko, powinniśmy zachować powyższe zalety zarządzanych obiektów w widokach. W rezultacie, powyższy kod ewoluuje w następujący sposób:

```swift
struct GroupCellViewRoot:View {
    @ObservedObject var group:C_Group
    var body:some View {
        let group = group.convertToGroup()
        GroupCellView(group:group)
    }
}
```

Niestety, wygląda na to, że wracamy do punktu wyjścia.

Aby zachować zalety Core Data, musimy wprowadzić zarządzane obiekty w widoku, co wymaga modelowania i konwersji.

Czy możliwe jest znalezienie sposobu, który mógłby zachować zalety zarządzanych obiektów, nie wprowadzając jednocześnie w sposób wyraźny konkretnych zarządzanych obiektów w kodzie?

#### Programowanie zorientowane na protokoły

Programowanie zorientowane na protokoły to podstawowe pojęcie, które przenika przez język Swift i jest jedną z jego głównych cech. Dzięki temu, że różne typy są zgodne z tym samym protokołem, programiści mogą uwolnić się od ograniczeń konkretnych typów.

#### BaseValueProtocol

Wróćmy do typu TodoGroup. Ten typ jest używany nie tylko do dostarczania danych dla widoków SwiftUI, ale także do dostarczania ważnych informacji dla innych przepływów danych. Na przykład, w ramach frameworków do Redux z Java Script, dostarcza on wymagane dane do reduktorów poprzez działania. 

> Redux wprowadza koncepcję jednego, globalnego obiektu stanu, który jest jedynym źródłem prawdy dla całego stanu aplikacji. Stan ten jest niemutowalny, co oznacza, że nie można go bezpośrednio modyfikować - zamiast tego, tworzy się nowe stany za pomocą funkcji zwanych reduktorami (reducers) na podstawie akcji (actions), które są wysyłane do magazynu (store).

Dlatego możemy stworzyć jednolity protokół dla wszystkich podobnych typów danych — BaseValueProtocol.

```swift
public protocol BaseValueProtocol: Equatable, Identifiable, Sendable {}
```

Coraz więcej frameworków typu Redux wymaga, aby Actions były zgodne z protokołem Equatable. Dlatego typy, które mogą potencjalnie być parametrami powiązanymi z Action, muszą również przestrzegać tego protokołu. Biorąc pod uwagę trend przenoszenia Reducerów poza główny wątek w przyszłości, zastosowanie danych zgodnych z Sendable może również uniknąć problemów związanych z wielowątkowością. Ponieważ każda instancja struktury wymaga odpowiadającej jej instancji zarządzanego obiektu, sprawienie, że typy struktury są zgodne z Identifiable, może lepiej nawiązać relację między nimi.

Teraz najpierw sprawimy, aby TodoGroup był zgodny z tym protokołem:

```swift
struct TodoGroup: BaseValueProtocol {
    var id: NSManagedObjectID // Link, który może połączyć dwie rzeczy, obecnie tymczasowo zastąpiony przez NSManagedObjectID
    var title: String
    var taskCount: Int
}
```

W powyższej implementacji używamy NSManagedObjectID jako typu id dla TodoGroup, ale ponieważ NSManagedObjectID również musi być tworzony w zarządzanym środowisku, zostanie on zastąpiony przez inne typy niestandardowe w dalszym tekście.



#### ConvertibleValueObservableObject

Bez względu na to, czy najpierw definiujemy model danych, czy strukturę, ostatecznie musimy dostarczyć metodę do konwersji zarządzanych obiektów na odpowiadające im struktury. Dlatego możemy rozważyć, że wszystkie zarządzane obiekty, które mogą być przekształcone na określoną strukturę (zgodną z BaseValueProtocol), powinny przestrzegać poniższego protokołu:

```swift
public protocol ConvertibleValueObservableObject<Value>: ObservableObject, Identifiable {
    associatedtype Value: BaseValueProtocol
    func convertToValueType() -> Value
}
```

Na przykład:

```swift
extension C_Group: ConvertibleValueObservableObject {
    public func convertToValueType() -> TodoGroup {
        .init(
            id: objectID, // Odpowiadający sobie identyfikator między nimi
            title: title ?? "",
            taskCount: tasks?.count ?? 0
        )
    }
}
```

#### Łącznik między nimi - WrappedID

Pomimo istnienia NSManagedObjectID, powyższe dwa protokoły wciąż nie mogą być odseparowane od zarządzanego środowiska (nie odnosząc się do frameworku Core Data). Dlatego musimy utworzyć typ pośredni, który może działać zarówno w zarządzanym, jak i niezarządzanym środowisku jako identyfikator dla obu.

```swift
public enum WrappedID: Equatable, Identifiable, Sendable, Hashable {
    case string(String)
    case integer(Int)
    case uuid(UUID)
    case objectID(NSManagedObjectID)
    
    public var id: Self {
        self
    }
}
```

Z tego samego powodu, że ten typ może być używany jako parametry powiązane z Action oraz jako jawny identyfikator widoków w ForEach, potrzebujemy, aby ten typ był zgodny z protokołami Equatable, Identifiable, Sendable i Hashable.

Ponieważ WrappedID musi być zgodny z Sendable, powyższy kod wygeneruje następujące ostrzeżenie podczas kompilacji (NSManagedObjectID nie jest zgodny z Sendable):



![img](https://miro.medium.com/v2/resize:fit:1400/0*V__CgTh086ldPnIE.png)

Na szczęście NSManagedObjectID jest bezpieczny dla wątków i może być oznaczony jako Sendable (to zostało oficjalnie potwierdzone przez Apple w Ask Apple Q&A 2022). Dodanie poniższego kodu wyeliminuje powyższe ostrzeżenie:

```swift
extension NSManagedObjectID: @unchecked Sendable {}
```

Dokonajmy kilku dostosowań w wcześniej zdefiniowanych BaseValueProtocol i ConvertibleValueObservableObject:

```swift
public protocol BaseValueProtocol: Equatable, Identifiable, Sendable {
    var id: WrappedID { get }
}

public protocol ConvertibleValueObservableObject<Value>: ObservableObject, Identifiable where ID == WrappedID {
    associatedtype Value: BaseValueProtocol
    func convertToValueType() -> Value
}
```

Do tej pory stworzyliśmy dwa protokoły i nowy typ — BaseValueProtocol, ConvertibleValueObservableObject i WrappedID, ale wydaje się, że nie jest jasne, jakie są ich konkretne cele.



#### Protokół do przygotowania danych testowych — TestableConvertibleValueObservableObject

Pamiętasz nasz pierwotny cel? Skończenie większości kodu widoku i logiki bez tworzenia modelu Core Data. Dlatego musimy być w stanie sprawić, że widok GroupCellViewRoot zaakceptuje uniwersalny typ, który może być stworzony tylko z struct (TodoGroup) i zachowuje się jak zarządzany obiekt. TestableConvertibleValueObservableObject jest kamieniem węgielnym osiągnięcia tego celu:

```swift
@dynamicMemberLookup
public protocol TestableConvertibleValueObservableObject<WrappedValue>: ConvertibleValueObservableObject {
    associatedtype WrappedValue where WrappedValue: BaseValueProtocol
    var _wrappedValue: WrappedValue { get set }
    init(_ wrappedValue: WrappedValue)
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<WrappedValue, Value>) -> Value { get set }
}

public extension TestableConvertibleValueObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<WrappedValue, Value>) -> Value {
        get {
            _wrappedValue[keyPath: keyPath]
        }
        set {
            self.objectWillChange.send()
            _wrappedValue[keyPath: keyPath] = newValue
        }
    }
    func update(_ wrappedValue: WrappedValue) {
        self.objectWillChange.send()
        _wrappedValue = wrappedValue
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._wrappedValue == rhs._wrappedValue
    }
    func convertToValueType() -> WrappedValue {
        _wrappedValue
    }
    var id: WrappedValue.ID {
        _wrappedValue.id
    }
}
```

Zdefiniujmy typ danych testowych, aby zweryfikować wyniki:

```swift
public final class MockGroup: TestableConvertibleValueObservableObject {
    public var _wrappedValue: TodoGroup
    public required init(_ wrappedValue: TodoGroup) {
        self._wrappedValue = wrappedValue
    }
}
```

Teraz, w widokach SwiftUI, MockGroup będzie miał prawie takie same możliwości jak C_Group, jedyna różnica polega na tym, że jest zbudowany przy użyciu instancji TodoGroup.

```swift


let group1 = TodoGroup(id: .string("Group1"), title: "Group1", taskCount: 5)
let mockGroup = MockGroup(group1)
```

Dzięki istnieniu WrappedID, mockGroup można używać bez zarządzanego środowiska.
AnyConvertibleValueObservableObject

Biorąc pod uwagę, że @ObservedObject może akceptować tylko konkretne typy danych (nie można używać dowolnego ConvertibleValueObservableObject), musimy stworzyć pojemnik wymazywania typów, aby zarówno C_Group, jak i MockGroup mogły być używane w widoku GroupCellViewRoot.

```swift
public class AnyConvertibleValueObservableObject<Value>: ObservableObject, Identifiable where Value: BaseValueProtocol {
    public var _object: any ConvertibleValueObservableObject<Value>
    public var id: WrappedID {
        _object.id
    }

    public var wrappedValue: Value {
        _object.convertToValueType()
    }
    init(object: some ConvertibleValueObservableObject<Value>) {
        self._object = object
    }
    public var objectWillChange: ObjectWillChangePublisher {
        _object.objectWillChange as! ObservableObjectPublisher
    }
}

public extension ConvertibleValueObservableObject {
    func eraseToAny() -> AnyConvertibleValueObservableObject<Value> {
        AnyConvertibleValueObservableObject(object: self)
    }
}
```

Teraz dokonajmy następujących dostosowań do widoku GroupCellViewRoot:

```swift
struct GroupCellViewRoot:View {
    @ObservedObject var group:AnyConvertibleValueObservableObject<TodoGroup>
    var body:some View {
        let group = group.wrappedValue
        GroupCellView(group:group)
    }
}
```

Zakończyliśmy pierwszy łańcuch widoków odłączony od zarządzanego środowiska.

Tworzenie podglądu

```swift
let group1 = TodoGroup(id: .string("Group1"), title: "Group1", taskCount: 5)
let mockGroup = MockGroup(group1)

struct GroupCellViewRootPreview: PreviewProvider {
    static var previews: some View {
        GroupCellViewRoot(group: mockGroup.eraseToAny())
            .previewLayout(.sizeThatFits)
    }
}
```

Być może niektórzy mogą myśleć, że użycie tak dużo kodu tylko po to, aby osiągnąć podgląd danych Mock, nie jest opłacalne. Jeśli celem jest po prostu to, wystarczyłoby bezpośrednie podglądanie widoku GroupCellView, dlaczego więc tyle kłopotów?

Bez AnyConvertibleValueObservableObject deweloperzy mogą tylko podglądać niektóre widoki w aplikacji (bez tworzenia zarządzanego środowiska). Jednak z AnyConvertibleValueObservableObject możemy osiągnąć pragnienie uwolnienia wszystkiego kodu widoku od zarządzanego środowiska. Łącząc metodę decouplingu wprowadzoną później z operacjami na danych Core Data, możliwe jest osiągnięcie celu ukończenia wszystkiego kodu logiki widoku i operacji na danych w aplikacji bez pisania jakiegokolwiek kodu Core Data. Co więcej, można to podglądać, jest interaktywne i można je przetestować na każdym etapie.

Przegląd

Nie daj się zmylić powyższym kodem. Po zastosowaniu metody wprowadzonej w tym artykule, nowo zorganizowany proces rozwoju wygląda następująco:

1. Definiuj strukturę TodoGroup

```swift
struct TodoGroup: BaseValueProtocol {
    var id: WrappedID
    var title: String
    var taskCount: Int // Liczba zadań w bieżącej grupie
}
```

2. Tworzenie TodoGroupView (w tym momencie TodoGroupViewRoot nie jest już potrzebny)

```swift
struct TodoGroupView:View {
    @ObservedObject var group:AnyConvertibleValueObservableObject<TodoGroup>
    var body:some View {
        let group = group.wrappedValue
        HStack {
            Text(group.title)
            Text("\(group.taskCount)")
        }
    }
}
```

3. Definiuj typ danych MockGroup

```swift
public final class MockGroup: TestableConvertibleValueObservableObject {
    public var _wrappedValue: TodoGroup
    public required init(_ wrappedValue: TodoGroup) {
        self._wrappedValue = wrappedValue
    }
}
```

```swift
let group1 = TodoGroup(id: .string("id1"), title: "Group1", taskCount: 5)
let mockGroup = MockGroup(group1)
```

4. Tworzenie podglądu widoku

```swift
struct GroupCellViewPreview: PreviewProvider {
    static var previews: some View {
        GroupCellView(group: mockGroup.eraseToAny())
    }
}
```



#### Tworzenie FetchRequest, które może używać danych Mock

Czy FetchRequest narusza jednokierunkowy przepływ danych?

Dla każdego dewelopera, który używa Core Data w SwiftUI, @FetchRequest to nieunikniony temat. FetchRequest znacznie upraszcza trudność pobierania danych Core Data w widoku. Za pomocą @ObservedObject (zarządzany obiekt zgodny z protokołem ObservableObject), deweloperzy mogą zaimplementować real-time reakcję na zmiany danych w widoku za pomocą kilku linijek kodu.

Jednak dla deweloperów, którzy przyjęli podejście jednokierunkowego przepływu danych, @FetchRequest jest jak miecz Damoklesa wiszący nad ich głowami, zawsze ich niepokoi. Framework klas Redux zazwyczaj zaleca deweloperom skomponowanie stanu całej aplikacji do jednej instancji strukturalnej (Stan, zgodny z protokołem Equatable), a widok reaguje na zmiany stanu przez ich obserwację (niektóre ramy obsługują obserwację typu slice, aby poprawić wydajność). Jednak @FetchRequest dzieli dużą część kompozycji stanu w aplikacji na wiele widoków z niezależnej instancji strukturalnej. W ostatnich latach wielu deweloperów próbowało znaleźć zamienniki, które są bardziej zgodne z duchem Redux, ale efekty są niezbyt dobrze zrozumiane.

Również ja podjąłem wiele prób, ale ostatecznie stwierdziłem, że FetchRequest wciąż wydaje się być najlepszym rozwiązaniem w obecnym SwiftUI. Pozwól, że krótko przedstawię mój proces eksploracji (na przykładzie frameworka TCA):

- Pobieranie i zarządzanie danymi wartości w Reducer

W funkcji zadania (lub onAppear), rozpocznij długoterminowy Efekt, wysyłając Action do utworzenia NSFetchedResultsController, aby pobrać zestaw danych z określonym predykatem z Core Data. W implementacji NSFetchedResultsControllerDelegate, przekształć zarządzane obiekty na odpowiadające im typy wartości i przekaż je do Reducera.

Użyj typu IdentifiedArray w State, aby przechować zestaw danych do podziału Reducera za pomocą .forEach.

Powyższe podejście jest rzeczywiście metodą, która w pełni jest zgodna z duchem Redux, ale ponieważ rezygnujemy z funkcji lazy-loading Core Data podczas konwersji zarządzanych obiektów na typy wartości, doprowadzi to do poważnych problemów z wydajnością i zużyciem pamięci, gdy objętość danych jest duża. Dlatego jest to odpowiednie tylko dla scenariuszy, w których zestaw danych jest mały.

- Pobieranie i zarządzanie AnyConvertibleValueObservableObject w Reducer

Podobnie jak w powyż

szej metodzie, ale pomijając proces konwersji na typy wartości, opakowuje zarządzany obiekt jako AnyConvertibleValueObservableObject i bezpośrednio zapisuje referencyjny typ w State. Jednak z uwagi na to, że TCA w późniejszym czasie przeniesie Reducer poza główny wątek, z perspektywy bezpieczeństwa wątkowego, ten plan został ostatecznie porzucony.

    Ponieważ ostatecznie musimy używać AnyConvertibleValueObservableObject (zarządzane obiekty) w widoku, proces pozyskiwania danych musi być przeprowadzany w kontekście głównego wątku (kontekst wiązania danych to ViewContext). Kiedy Reducer jest przenoszony poza główny wątek, oznacza to, że AnyConvertibleValueObservableObject będzie zapisywane w instancji State bez wątku. Chociaż w praktyce trzymanie zarządzanego obiektu w wątku innym niż ten, który stworzył zarządzany obiekt, nie spowoduje awarii, o ile nie są dostępne właściwości zarządzanego obiektu, które nie są bezpieczne dla wątków, z ostrożności ostatecznie zrezygnowałem z tego podejścia.

- Pobieranie i zarządzanie WrappedID w Reducer

Podobnie jak powyżej, zapisz tylko bezpieczne dla wątków WrappedID (opakowany NSManagedObjectID) w State. W widoku, użyj WrappedID, aby uzyskać odpowiedni AnyConvertibleValueObservableObject lub typ wartości. Chociaż może to zwiększyć kod w widoku, ta metoda jest prawie doskonała zarówno z perspektywy przetwarzania przepływu danych, jak i bezpieczeństwa wątkowego.

Jednak powodem, dla którego ostatecznie zrezygnowałem z wszystkich powyższych prób, były problemy z wydajnością.

- Każda zmiana w Core Data skutkuje zmianą pojedynczego Stanu aplikacji. Chociaż TCA ma mechanizmy podziału, wraz ze wzrostem złożoności i ilości danych w aplikacji, problemy z wydajnością spowodowane porównywaniem Stanu stają się coraz poważniejsze.
- Operacja tworzenia NSFetchedResultsController i uzyskania początkowej partii danych jest inicjowana od onAppear. Ze względu na mechanizm obsługi Akcji TCA, istnieje zauważalne opóźnienie w początkowym wyświetlaniu danych (znacznie mniej efektywne niż pobieranie danych przez FetchRequest w widoku).
- Ze względu na to, że Reducer TCA nie jest w stanie automatycznie wiązać się z cyklem życia widoku, wspomniane powyżej zauważalne opóźnienie wystąpi za każdym razem, gdy jest wyzwalane onAppear.

W końcu zdecydowałem się uwolnić swoje obawy i nadal używać podejścia @FetchRequest do pobierania danych w widoku. Tworząc nowy FetchRequest, który może korzystać z danych mock, osiągnąłem cel testowalności, podglądu i modularności, o którym wspomniano w artykule "SwiftUI and Core Data: The Challenges".

#### NSFetchedResultsController

NSFetchedResultsController pobiera określony zestaw danych z Core Data za pomocą NSFetchRequest i wysyła zestaw danych do instancji, które są zgodne z protokołem NSFetchedResultsControllerDelegate, aby zaimplementować metody wyświetlania danych na ekranie.

Mówiąc prosto, NSFetchedResultsController automatycznie aktualizuje zestaw danych w pamięci w odpowiedzi na powiadomienia NSManagedObjectContextObjectsDidChange i NSManagedObjectContextDidMergeChangesObjectIDs po uzyskaniu początkowego zestawu danych (performFetch) na podstawie treści powiadomienia (wstawienie, usunięcie, aktualizacja itp.). Aby poprawić efektywność aktualizacji UITableView (UICollectionView), NSFetchedResultsController rozkłada zmiany w danych na konkretne akcje (NSFetchRequestResultType), aby deweloperzy mogli szybko dostosować wyświetlaną zawartość UITableView (bez odświeżania wszystkich danych).

Niestety, optymalizacje oparte na NSFetchRequestResultType przygotowane przez NSFetchedResultsController dla UITableView nie działają w SwiftUI. W SwiftUI, ForEach automatycznie obsługuje dodawanie widoków, usuwanie i inne operacje na podstawie identyfikatorów danych (Identifier). Dlatego, gdy używamy NSFetchedResultsController w SwiftUI, tylko metoda controllerDidChangeContent(_ controller:) w NSFetchedResultsControllerDelegate musi być zaimplementowana.

#### Własne typy zgodne z protokołem DynamicProperty

W SwiftUI, typy, które mogą służyć jako źródło prawdy, zwykle są zgodne z protokołem DynamicProperty. Protokół DynamicProperty umożliwia dostęp do zarządzanego przez SwiftUI puli danych dla danych. Za pomocą prywatnej metody _makeProperty, dane mogą żądać miejsca w puli danych SwiftUI do przechowywania i pobierania. Służy to dwóm celom:

- Zmiany w danych spowodują aktualizacje w widokach, które są do nich związane.
- Ponieważ dane zasadnicze nie są przechowywane w widoku, SwiftUI może tworzyć nowe instancje opisu widoku w dowolnym momencie podczas życia widoku, nie martwiąc się o utratę danych.

Chociaż Apple nie ujawniło szczegółów metody _makeProperty, deweloperzy nie mogą sami żądać adresów przechowywania danych od SwiftUI. Jednak podobne efekty można osiągnąć, używając typów, które są zgodne z protokołem `DynamicProperty`, takich jak State, w własnych typach, które również są zgodne z protokołem `DynamicProperty`.

Podczas tworzenia niestandardowego typu zgodnego z protokołem DynamicProperty, ważne jest, aby pamiętać o następujących kwestiach:

- Wartości lub obiekty środowiskowe mogą być używane w niestandardowych typach**

Po załadowaniu widoku, wszystkie typy zgodne z protokołem DynamicProperty będą miały możliwość dostępu do danych środowiskowych. Próba dostępu do danych środowiskowych przed załadowaniem widoku lub bez dostarczania wartości środowiskowych (na przykład zapominając o wstrzyknięciu obiektu środowiskowego lub nie dostarczając poprawnego kontekstu widoku) spowoduje awarię.

- Niestandardowe typy zostaną również odtworzone, gdy SwiftUI odtworzy instancję opisu widoku w trakcie trwania widoku**

Podczas trwania widoku, jeśli SwiftUI odtworzy instancję opisu widoku, wówczas odtworzy wszystkie właściwości, niezależnie od tego, czy są zgodne z DynamicProperty, czy nie. Oznacza to, że trwałe dane (zgodne z czasem trwania widoku) muszą być zapisane w typie DynamicProperty dostarczanym przez system.

- Metoda aktualizacji zostanie wywołana dopiero po załadowaniu widoku przez SwiftUI**

Jedyną metodą udostępnioną przez protokół DynamicProperty jest metoda aktualizacji. SwiftUI wywoła tę metodę, gdy widok zostanie po raz pierwszy załadowany oraz gdy dane, które mogą wywołać aktualizację widoku, ulegną zmianie w typie zgodnym z DynamicProperty. Ponieważ instancje typu mogą być wielokrotnie tworzone w trakcie trwania widoku, przygotowanie danych (takie jak pobieranie danych NSFetchedResultsController po raz pierwszy, tworzenie relacji subskrypcji) i prace aktualizacyjne powinny być wykonywane w tej metodzie.

- Dane wywołujące aktualizację widoku nie mogą być synchronicznie zmieniane w metodzie aktualizacji**

Tak jak przy aktualizacji źródła prawdy w widokach SwiftUI, w cyklu aktualizacji widoku, źródło prawdy nie może być ponownie aktualizowane. Oznacza to, że mimo że możemy zmieniać dane tylko w metodzie aktualizacji, musimy znaleźć sposób na rozłożenie tego cyklu aktualizacji.



#### Wykorzystanie `MockableFetchRequest`

`MockableFetchRequest` dostarcza możliwość dynamicznego pobierania danych podobnie jak `FetchRequest`, ale z następującymi cechami:

- `MockableFetchRequest` zwraca dane typu `AnyConvertibleValueObservableObject`.**

    `NSFetchedResultsController` w `MockableFetchRequest` bezpośrednio konwertuje dane do typu `AnyConvertibleValueObservableObject`. Pozwala to na bezpośrednie korzystanie z różnych korzyści wprowadzonych w poprzednim dziale w widoku. Ponadto, podczas deklarowania `MockableFetchRequest` w widoku, można uniknąć używania konkretnych typów zarządzanych obiektów, co sprzyja modularnemu rozwoju.

    ```swift
    @MockableFetchRequest(\ObjectsDataSource.groups) var groups // Kod nie jest zanieczyszczony konkretnymi typami zarządzanych obiektów
    ```

- Przełączanie źródeł danych za pomocą wartości środowiskowych.**

W poprzednim dziale, dostarczyliśmy możliwość podglądu bez zarządzanego środowiska dla widoku zawierającego pojedynczy obiekt `AnyConvertibleValueObservableObject` przez tworzenie danych zgodnych z protokołem `TestableConvertibleValueObservableObject`. `MockableFetchRequest` dostarcza możliwość podglądu zestawu danych bez zarządzanego środowiska dla widoku, który pobiera zestaw danych.

Najpierw musimy utworzyć typ, który jest zgodny z protokołem `ObjectsDataSourceProtocol` i określa źródło danych poprzez tworzenie właściwości typu `FetchDataSource`.

~~~swift
```swift
// Zawarte w kodzie MockableFetchRequest
public enum FetchDataSource<Value>: Equatable where Value: BaseValueProtocol {
    case fetchRequest // pobiera dane przez NSFetchedResultsController w MockableFetchRequest
    case mockObjects(EquatableObjects<Value>) // korzysta z dostarczonych danych typu Mock
}

public extension EnvironmentValues {
    var dataSource: any ObjectsDataSourceProtocol {
        get { self[ObjectsDataSourceKey.self] }
        set { self[ObjectsDataSourceKey.self] = newValue }
    }
}
// Kod, który deweloperzy muszą dostosować
public struct ObjectsDataSource: ObjectsDataSourceProtocol {
    public var groups: FetchDataSource<TodoGroup>
}
public struct ObjectsDataSourceKey: EnvironmentKey {
    public static var defaultValue: any ObjectsDataSourceProtocol = ObjectsDataSource(groups: .mockObjects(.init([MockGroup(.sample1).eraseToAny()]))) // Ustala domyślne źródło danych na dane typu Mock
}
```
~~~

Można dokonywać modyfikacji danych w czasie rzeczywistym podczas podglądu (zobacz kod `GroupListContainer` w `Todo` po więcej szczegółów). 
    

![img](https://miro.medium.com/v2/resize:fit:1400/0*vguLmdDEQh11YJ0p.png)


Gdy aplikacja działa w środowisku hostowanym, wystarczy dostarczyć poprawny kontekst widoku i zmodyfikować wartości właściwości w `dataSource` na `fetchRequest`.

![img](https://miro.medium.com/v2/resize:fit:1400/0*D3TXRQuwFRIfAbAl.png)



- **Pozwalaj na niepodawanie `NSFetchRequest` w konstruktorze.**

    Podczas korzystania z `@FetchRequest` w widoku, musimy ustawić `NSFetchRequest` (lub `NSPredicate`) podczas deklarowania zmiennej `FetchRequest`. W rezultacie, kiedy wydzielamy widok do osobnego pakietu, wciąż musimy importować bibliotekę zawierającą definicje specyficznych zarządzanych obiektów Core Data, co uniemożliwia pełne odłączenie. W `MockableFetchRequest`, nie ma potrzeby dostarczania `NSFetchRequest` podczas deklarowania, a wymagane `NSFetchRequest` można dynamicznie dostarczyć dla `MockableFetchRequest` kiedy widok jest ładowany (szczegółowy kod demonstracyjny).

    ```swift
    public struct GroupListView: View {
        @MockableFetchRequest(\ObjectsDataSource.groups) var groups
        @Environment(\.getTodoGroupRequest) var getTodoGroupRequest

        public var body: some View {
            List {
                    ForEach(groups) { group in
                        GroupCell(
                            groupObject: group,
                            deletedGroupButtonTapped: deletedGroupButtonTapped,
                            updateGroupButtonTapped: updateGroupButtonTapped,
                            groupCellTapped: groupCellTapped
                        )
                    }
            }
            .task {
                guard let request = await getTodoGroupRequest() else { return } // Dynamically obtain the required Request through the environment method when the view is loaded
                $groups = request // Dynamically set MockableFetchRequest
            }
            .navigationTitle("Todo Groups")
        }
    }
    ```

- **Unikaj aktualizacji zestawów danych za pomocą operacji, które nie powodują zmiany ID.**

    `MockableFetchRequest` nie aktualizuje zestawu danych nawet jeśli wartości atrybutów danych zmieniają się, o ile sekwencja ID lub ilość danych w zestawie pozostaje niezmieniona. Ponieważ `AnyConvertibleValueObservableObject` sam w sobie jest zgodny z protokołem `ObservableObject`, nawet jeśli `MockableFetchRequest` nie aktualizuje zestawu danych, widok nadal reaguje na zmiany właściwości `AnyConvertibleValueObservableObject`. Zmniejsza to częstotliwość zmian w zestawie danych `ForEach`, poprawiając wydajność widoków SwiftUI.

- **Dostarcza lżejszy `Publisher` do monitorowania zmian danych.**

    Oryginalny `FetchRequest` dostarcza `Publisher` (poprzez wartość projekcji) który reaguje na każdą zmianę zestawu danych. Jednakże, ten `Publisher` reaguje zbyt często i nawet jeśli tylko jeden atrybut danych w zestawie zmienia się, wydaje on wszystkie dane w zestawie. `MockableFetchRequest` upraszcza to, wydając pustą powiadomienie (`AnyPublisher<Void, Never>`) tylko kiedy zestaw danych się zmienia.

    ```swift
    public struct GroupListView: View {
        @MockableFetchRequest(\ObjectsDataSource.groups) var groups
    
        public var body: some View {
            List {
               ...
            }
            .onReceive(_groups.publisher){ _ in
                print("data changed")


           }
        }
    }
    ```

- **Aby osiągnąć taki sam efekt jak `@FetchRequest`, wystarczy podnieść uprawnienia właściwości nadawcy.**

    Poniższy obrazek to demonstracja podglądu całkowicie stworzona z danymi mock:

![img](https://miro.medium.com/v2/resize:fit:1400/0*wYpe0vBh7QbPShqB.gif)

Koncept opcjonalnych atrybutów obiektów zarządzanych (managed objects) w Core Data istniał przed pojawieniem się języka Swift i umożliwiał tymczasowe ustawienie właściwości jako nieprawidłowe (nil). Na przykład, gdy tworzysz nowy obiekt NSManagedObject z atrybutem typu String, wartość początkowa (bez domyślnej wartości) to nil, co nie stanowi problemu przed walidacją obiektu (zazwyczaj podczas zapisu).

Jeśli deweloper ustawia domyślną wartość dla atrybutu w edytorze modeli (wyłączając opcję opcjonalności), generowany przez Xcode kod definicji klasy obiektu zarządzanego nadal deklaruje wiele typów jako opcjonalne. Poprzez ręczną modyfikację typu (zmianę String? na String), kod deklaracji może częściowo poprawić przyjazność użytkowania obiektów zarządzanych w widoku.

W porównaniu do deklaracji właściwości z domyślnymi wartościami jako opcjonalne (np. String?), deklarowanie właściwości numerycznych jest bardziej mylące. Na przykład, właściwość count (Integer 16) w edytorze modeli jest ustawiona jako opcjonalna, ale w wygenerowanym kodzie nadal jest to nieopcjonalny typ wartości (Int16).

![img](https://miro.medium.com/v2/resize:fit:1400/1*-BsPRvVa6WI2pi8hUdS5Cg.png)

![img](https://miro.medium.com/v2/resize:fit:1400/1*mdDM1ZocNjdco_mOVIbP5g.png)



Ponadto, deweloperzy nie mogą zmienić typu właściwości na Int16? poprzez modyfikację kodu deklaracji.

![img](https://miro.medium.com/v2/resize:fit:1400/1*6F0-KQbeMHUUirsNTgCrLQ.png)

Oznacza to, że deweloperzy utracą potężne możliwości opcjonalnych wartości w języku Swift dla określonych typów atrybutów encji. Powodem tego jest fakt, że "opcjonalne" w edytorze modeli w Xcode nie odpowiada opcjonalnym wartościom w języku Swift. Core Data jest ograniczona przez restrykcje typów możliwych do wyrażenia w Objective-C, i nawet przy konwersji skalarnych typów, nie jest w stanie odzwierciedlić natywnych typów w Swift.

Jeśli usuniemy typy skalarnych wartości, możemy pozwolić edytorowi modeli generować konkretne typy, które obsługują opcjonalne wartości (takie jak NSNumber?).

![img](https://miro.medium.com/v2/resize:fit:1400/1*432JkMZtH_QxvyW_jfqYDA.png)



![img](https://miro.medium.com/v2/resize:fit:1400/1*6gGHYrjGweLZ7AKqASxTLw.png)

Deweloperzy mogą zadeklarować obliczane właściwości dla obiektów zarządzanych w celu realizacji konwersji między NSNumber? a Int16?.

Deweloperzy mogą zastanawiać się, czy mogą użyć wykrzyknika (!) do wymuszenia rozwinięcia opcjonalnej właściwości encji, która jest zdefiniowana jako opcjonalna w modelu i zadeklarowana jako opcjonalny typ wartości w deklaracji typu obiektu zarządzanego (np. wspomniana wyżej właściwość timestamp), o ile mogą zapewnić istnienie wartości do zapisu.

Faktycznie, taka właśnie metoda jest używana w szablonie Core Data dostarczanym przez Xcode.

![img](https://miro.medium.com/v2/resize:fit:1400/1*FIQJMxFPDn8UcUtksOrt0Q.png)



Czy takie użycie jest naprawdę poprawne? Czy mogą istnieć poważne ryzyka bezpieczeństwa? Jeśli pole w bazie danych odpowiadające znacznikowi czasu ma wartość, czy znacznik czasu zawsze będzie miał wartość? Czy możliwe jest, żeby był równy nil?
Usuwanie i programowanie reaktywne

Instancje obiektów zarządzanych są tworzone w kontekście zarządzanym i mogą działać bezpiecznie tylko w wątku kontekstu zarządzanego, do którego są przypisane. Każdy zarządzany obiekt odpowiada rekordowi w trwałym przechowywaniu (z wyłączeniem relacji).

Aby zaoszczędzić pamięć, obiekt hostujący będzie aktywnie zwalniał miejsce zajmowane przez nieużywane instancje zarządzanych obiektów (domyślnie retainsRegisteredObjects jest ustawione na false) w dystrybucji od góry do dołu. Innymi słowy, jeśli widok używany do wyświetlania danych instancji zarządzanego obiektu zostanie zniszczony i jeśli nie ma innych widoków ani kodu odwołującego się do instancji zarządzanego obiektu wyświetlanego w widoku, kontekst hostujący zwolni pamięć zajmowaną przez te dane z pamięci.

Kiedy retainsRegisteredObjects jest ustawione na true, zarządzane obiekty są wewnętrznie przechowywane za pomocą silnego odwołania, nawet jeśli nie ma zewnętrznego kodu odwołującego się do instancji zarządzanego obiektu, instancja obiektu nie zostanie zniszczona.

Z innej perspektywy, nawet jeśli metoda delete jest używana w kontekście zarządzanym do usunięcia danych odpowiadających instancji w bazie danych, jeśli instancja obiektu zarządzanego jest wciąż odwoływana przez kod lub widoki, Swift nie zniszczy instancji. W tym momencie kontekst zarządzany ustawia właściwość managedObjectContext instancji na nil, co anuluje powiązanie z kontekstem zarządzanym. Jeśli ponownie zostanie uzyskany dostęp do opcjonalnej wartości typu wartościowego (takiej jak znacznik czasu), który musiał mieć wartość wcześniej, wartość zwrócona będzie równa nil. Wymuszenie rozwinięcia go spowoduje awarię aplikacji.

Wraz z popularyzacją synchronizacji w chmurze i śledzenia historii przechowywania danych, pewne dane w bazie danych Core Data mogą być usuwane przez inne urządzenia lub inne procesy korzystające z tej same

Przepraszam za pominięcie. Oto przetłumaczony wstęp przed kodem:

Powracając do kodu szablonu Core Data stworzonego przez Xcode, próbujemy dokonać następującej operacji: usunięcia danych jeden sekundę po wejściu do NavigationLink.

Poniżej przedstawiony jest kod, który implementuje to działanie:

```swift
ForEach(items) { item in
    NavigationLink {
        Text("Element o czasie \(item.timestamp!, formatter: itemFormatter)")
            .onAppear{
                // Usunięcie danych jeden sekundę po wejściu do NavigationLink
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    viewContext.delete(item)
                    try! viewContext.save()
                }
            }
    } label: {
        Text(item.timestamp!, formatter: itemFormatter)
    }
}
```

![img](https://miro.medium.com/v2/resize:fit:1032/1*RNTfzzmQmrsDguNtZT5vZg.gif)

Nie było żadnych problemów! W ogóle nie zawiesił się. Czy to możliwe, że nasza poprzednia dyskusja była całkowicie błędna?

W kodzie szablonu `Core Data` do deklaracji podwidoków używa się tylko jednej linii kodu:

`Text("Element z \(item.timestamp!, formatter: itemFormatter)")`

Dlatego też, w `ForEach` `ContentView`, `item` nie jest traktowany jako źródło prawdy, które może wywołać aktualizacje widoku (elementy uzyskane przez `Fetch Request` są źródłem prawdy). Po usunięciu danych, nawet jeśli zawartość `item` się zmieniła, wyrażenie deklarujące tę kolumnę (`Text`) nie zostanie odświeżone, więc nie dojdzie do awarii związanej z wymuszonym rozpakowaniem. Jak zawartość `FetchRequest` zmienia się, `List` zostanie odświeżony ponownie. Ponieważ dane odpowiadające `NavigationLink` już nie istnieją, `NavigationView` automatycznie powraca do widoku głównego.

Jednak zazwyczaj w podwidoku używamy `ObservedObject`, aby oznaczyć instancję zarządzanego obiektu w celu reagowania na zmiany danych w czasie rzeczywistym. Dlatego, jeśli dostosujemy kod do normalnego trybu pisania, możemy zobaczyć, gdzie jest problem:

```swift
struct Cell:View {
    @ObservedObject var item:Item // Reaguje na zmiany danych
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        Text("Element z \(item.timestamp!, formatter: itemFormatter)")
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    viewContext.delete(item)
                    try! viewContext.save()
                }
            }
    }
}

List {
    ForEach(items) { item in
        NavigationLink {
            Cell(item: item) // Przekazuje zarządzany obiekt
        } label: {
            Text(item.timestamp!, formatter: itemFormatter)
        }
    }
    .onDelete(perform: deleteItems)
}
```









![img](https://miro.medium.com/v2/resize:fit:1400/1*sccWW22p3TDDBJgItDWm2g.gif)



Po usunięciu danych, kontekst zarządzanego obiektu ustawia `manageObjectContext` elementu na wartość `nil`. W tym momencie widok `Cell` odświeży się, kierowany przez `ObjectWillChangePublisher` elementu, a wymuszanie rozpakowania spowoduje awarię aplikacji. Można uniknąć tego problemu, dostarczając wartości alternatywne.

`Text("Element z \(item.timestamp ?? .now, formatter: itemFormatter)")`

Co jeśli użyjemy protokołu `ConvertibleValueObservableObject`, omówionego w naszym artykule "SwiftUI i Core Data: Definicja Danych"? Czy dostarczenie wartości alternatywnych dla właściwości w `convertToValueType` może zapobiec awariom? Odpowiedź brzmi, że oryginalna wersja może nadal mieć problemy.

Po usunięciu danych, `manageObjectContext` hostowanego obiektu instancji jest ustawione na `nil`. Ponieważ `AnyConvertibleValueObservableObject` zgodny jest z protokołem `ObservableObject`, wywoła również aktualizację widoku `Cell`. W nowym cyklu renderowania, jeśli ograniczymy proces konwersji `convertToGroup` do działania na wątku, na którym znajduje się kontekst zarządzanego obiektu, konwersja nie powiedzie się z powodu niemożności uzyskania informacji o kontekście. Zakładając, że nie ograniczamy wątku, na którym działa proces konwersji, metoda awaryjna będzie nadal ważna dla instancji zarządzanego obiektu stworzonych przez kontekst widoku (ale mogą wystąpić inne błędy wątków).

Aby protokół `ConvertibleValueObservableObject` spełniał różne scenariusze, musimy dokonać następujących dostosowań:

```swift
public protocol ConvertibleValueObservableObject<Value>: ObservableObject, Equatable, Identifiable where ID == WrappedID {
    associatedtype Value: BaseValueProtocol
    func convertToValueType() -> Value? // Zmiana typu zwracanego na Value?
}

public extension TestableConvertibleValueObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    ...
    func convertToValueType() -> WrappedValue? { // Zmiana na zwracanie Value?
        _wrappedValue
    }
}
public class AnyConvertibleValueObservableObject<Value>: ObservableObject, Identifiable where Value: BaseValueProtocol {
    public var wrappedValue: Value? { // Zmiana na zwracanie Value?
        _object.convertToValueType()
    }
}
```

Dzięki temu, możemy użyć `if let` w kodzie widoku, aby zapewnić, że wspomniany wyżej problem z awarią nie wystąpi:

```swift
public struct Cell: View {
    @ObservedObject var item: AnyConvertibleValueObservableObject<Item>

    public var body: some View {
        if let item = item.wrappedValue {
           Text("Element z \(item.timestamp, formatter: itemFormatter)")
        }
    }
}
```

Aby obsługiwać konwersję w dowolnym wątku kontekstu hostingowego

, implementacja `convertToValueType` będzie wyglądać następująco, biorąc `TodoGroup` w `Todo` jako przykład:

```swift
extension C_Group: ConvertibleValueObservableObject {
    public var id: WrappedID {
        .objectID(objectID)
    }

    public func convertToValueType() -> TodoGroup? {
        guard let context = managedObjectContext else { // Sprawdź, czy kontekst jest dostępny
            return nil
        }
        return context.performAndWait { // Wykonaj w wątku kontekstu, aby zapewnić bezpieczeństwo wątku
            TodoGroup(
                id: id,
                title: title ?? "",
                taskCount: tasks?.count ?? 0
            )
        }
    }
}
```

Ponieważ synchroniczna wersja `performAndWait` nie obsługuje wartości zwracanych, musimy ją nieco rozszerzyć:

```swift
extension NSManagedObjectContext {
    @discardableResult
    func performAndWait<T>(_ block: () throws -> T) throws -> T {
        var result: Result<T, Error>?
        performAndWait {
            result = Result { try block() }
        }
        return try result!.get()
    }

    @discardableResult
    func performAndWait<T>(_ block: () -> T) -> T {
        var result: T?
        performAndWait {
            result = block()
        }
        return result!
    }
}
```

W programowaniu reaktywnym, programiści nie powinni zakładać, że każdy komponent może być w idealnym środowisku, i powinni dążyć do zapewnienia, że mogą być bezpieczne i stabilne w każdej sytuacji, aby zapewnić stabilne działanie całego systemu.

Dostarcz właściwej alternatywnej treści dla usuniętych instancji zarządzanego obiektu.

Niektórzy mogą uznać tytuł tej sekcji za dziwny. Jeśli zarządzany obiekt został już usunięty, jakie informacje trzeba dostarczyć?

W poprzednim demo, kiedy dane są usuwane (poprzez użycie opóźnionej operacji w zamknięciu `onAppear`), `NavigationView` automatycznie wraca do widoku głównego. W tym przypadku, widok, który przechowuje dane, zniknie wraz z usunięciem danych.

Jednak w wielu przypadkach, programiści mogą nie używać wersji `NavigationLink`, używanej w demo. Aby mieć silniejszą kontrolę nad widokiem, programiści zazwyczaj wybierają programowalną wersję `NavigationLink`. W takim przypadku, kiedy dane są usuwane, aplikacja nie wróci automatycznie do widoku głównego. Dodatkowo, w niektórych innych operacjach, aby zapewnić stabilność widoku modalnego, zazwyczaj montujemy widok modalny poza `List`. Na przykład:

```swift
@State var item: Item?

List {
    ForEach(items) { item in
        VStack {
            Text("\(item.timestamp ?? .now)")
            Button("Pokaż

 szczegóły") {
                self.item = item // Pokaż widok modalny
                // Symuluj opóźnione usuwanie
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    viewContext.delete(item)
                    try! viewContext.save()
                }
            }
            .buttonStyle(.bordered)
        }
    }
    .onDelete(perform: deleteItems)
}
// Widok modalny
.sheet(item: $item) { item in
    Cell(item: item)
}
struct Cell: View {
    @ObservedObject var item: Item
    var body: some View {
        // Aby zobaczyć zmianę wyraźnie. Kiedy timestamp jest nil, wyświetlany jest obecny czas.
        Text("\((item.timestamp ?? .now).timeIntervalSince1970)")
    }
}
```

Gdy uruchomimy powyższy kod, po usunięciu danych, `item` w widoku `Sheet` użyje alternatywnych danych, ponieważ `manageObjectContext` jest `nil`, co może wprowadzić użytkownika w błąd.







![img](https://miro.medium.com/v2/resize:fit:1000/1*tAO3Zb_CzLUxt1e2WW37fA.gif)



Możemy uniknąć powyższego problemu, zatrzymując prawidłowe wartości.

```swift
struct Cell: View {
    let item: Item // Nie ma potrzeby używania ObservedObject
    /*
     Jeśli używasz MockableFetchRequest, to
     let item: AnyConvertibleValueObservableObject<ItemValue>
    */
    @State var itemValue: ItemValue?
    init(item: Item) {
        self.item = item
        // Kiedy jest inicjalizowany, uzyskaj prawidłową wartość
        self._itemValue = State(wrappedValue: item.convertToValueType())
    }
    var body: some View {
        VStack {
            if let itemValue {
                Text("\((itemValue.timestamp).timeIntervalSince1970)")
            }
        }
        .onReceive(item.objectWillChange){ _ in
            // Po zmianie elementu, jeśli można go przekonwertować na prawidłową wartość, zaktualizuj widok
            if let itemValue = item.convertToValueType() {
                self.itemValue = itemValue
            }
        }
    }
}

public struct ItemValue: BaseValueProtocol {
    public var id: WrappedID
    public var timestamp: Date
}
extension Item: ConvertibleValueObservableObject {
    public var id: WrappedID {
        .objectID(objectID)
    }
    public func convertToValueType() -> ItemValue? {
        guard let context = managedObjectContext else { return nil }
        return context.performAndWait{
            ItemValue(id: id, timestamp: timestamp ?? .now)
        }
    }
}
```





![img](https://miro.medium.com/v2/resize:fit:1000/1*ELoZ3Sxy5Q-wxtF2oiDJRA.gif)



Przekazywanie typów wartości poza widokami

W poprzednim kodzie przekazaliśmy tylko instancje zarządzanych obiektów dla subwidoków (AnyConvertibleValueObservableObject jest również wtórnym opakowaniem dla instancji zarządzanych obiektów). Ale w ramce klasy Redux, dla bezpieczeństwa wątków (Reducers mogą nie działać w głównym wątku, proszę zobaczyć poprzednie artykuły), nie wysyłamy bezpośrednio instancji zarządzanych obiektów do Reducera, ale przekazujemy przekształcone typy wartości.

    Poniższy kod pochodzi z pliku TaskListContainer.swift w projekcie Todo TCA Target.

![img](https://miro.medium.com/v2/resize:fit:1400/1*6T9lvcSFGjrD9aX4y2hCfQ.png)

Chociaż typy wartości pomagają nam uniknąć potencjalnych ryzyk związanych z wątkami, pojawia się nowy problem, gdzie widoki nie mogą reagować w czasie rzeczywistym na zmiany w instancjach zarządzanych obiektów. Przez uzyskanie instancji zarządzanego obiektu odpowiadającej danym typu wartości w widoku, możemy zapewnić zarówno bezpieczeństwo, jak i reaktywność w czasie rzeczywistym.

Dla wygody demonstracji, nadal używamy zwykłego przepływu danych SwiftUI jako przykładu:

```swift
@State var item: ItemValue? // typ wartości

List {
    ForEach(items) { item in
        VStack {
            Text("\(item.timestamp ?? .now)")
            Button("Pokaż szczegóły") {
                self.itemValue = item.convertToValueType() // przekazanie typu wartości
                // symulacja opóźnionej modyfikacji zawartości
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    item.timestamp = .now
                    try! viewContext.save()
                }
            }
            .buttonStyle(.bordered)
        }
    }
    .onDelete(perform: deleteItems)
}
.sheet(item: $itemValue) { item in
    Cell(itemValue: item) // parametr to typ wartości
}
struct Cell: View {
    @State var itemValue: ItemValue // typ wartości
    @Environment(\.managedObjectContext) var context
    var body: some View {
        VStack {
            if let itemValue {
                Text("\((itemValue.timestamp).timeIntervalSince1970)")
            }
        }
        // pobranie odpowiedniej instancji zarządzanego obiektu w widoku i reagowanie na zmiany w czasie rzeczywistym
        .task { @MainActor in
            guard case .objectID(let id) = itemValue.id else {return}
            if let item = try? context.existingObject(with: id) as? Item {
                for await _ in item.objectWillChange.values {
                    if let itemValue = item.convertToValueType() {
                        self.itemValue = itemValue
                    }
                }
            }
        }
    }
}
```

Na podstawie mojego doświadczenia, aby zapewnić bezpieczeństwo wątku, zarządzane obiekty powinny być przekazywane tylko pomiędzy widokami, a najlepiej jest tylko uzyskiwać dane używane do wyświetlania widoku w obrębie widoku. Każdy możliwy proces transferu, który może być odseparowany od widoku, powinien korzystać z wersji typu wartości instancji zarządzanego obiektu.

Wykonaj drugorzędne potwierdzenie podczas modyfikacji danych

Aby uniknąć nadmiernego wpływu na główny wątek, zazwyczaj wykonujemy operacje, które spowodują zmiany danych w prywatnym kontekście. Ustawienie parametru metody operacyjnej na typ wartości zmusza programistów do najpierw potwier

dzenia, czy odpowiednie dane (w bazie danych) istnieją, gdy operują na danych (takich jak dodawanie, usuwanie i zmiana).

Na przykład (kod z CoreDataStack.swift w projekcie Todo):

```swift
@Sendable
func _updateTask(_ sourceTask: TodoTask) async {
    await container.performBackgroundTask { [weak self] context in
        // Najpierw potwierdź, czy zadanie istnieje
        guard case .objectID(let taskID) = sourceTask.id,
              let task = try? context.existingObject(with: taskID) as? C_Task else {
            self?.logger.error("Nie mogę uzyskać zadania przez \(sourceTask.id)")
            return
        }
        task.priority = Int16(sourceTask.priority.rawValue)
        task.title = sourceTask.title
        task.completed = sourceTask.completed
        task.myDay = sourceTask.myDay
        self?.save(context)
    }
}
```

Przez `existingObject`, zapewniamy, że kolejny krok operacji jest wykonany tylko wtedy, gdy dane są ważne, co pozwala uniknąć nieoczekiwanych awarii spowodowanych działaniem na usuniętych danych.




