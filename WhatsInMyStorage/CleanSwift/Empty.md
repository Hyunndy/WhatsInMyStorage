#  <#Title#>

# Clean Architecture

로버트 C 마틴이 고안한 아키텍처

마틴이 보았던 수많은 아키텍처들은 공통의 특징을 갖고 있음

- 같은 목표를 가짐
- 소프트웨어를 계층(layer)로 나눠서 관심사를 분리함.

→ 결국 수많은 아키텍처가 다음과 같은 목표를 이루고자함

### 목표

1. Independent of Frameworks
    1. 아키텍처는 소프트웨어 라이브러리의 존재에 의존하지 않음
2. Testable
    1. 비즈니스 로직은 UI, DB, 웹 서버 또는 기타 외부 요소 없이 테스트 할 수 있음
3. Indepenent of UI
    1. UI는 시스템을 변경하지 않고도 쉽게 변경 가능(ex. 비지니스 로직을 변경하지 않고 UI 변경 가능)
4. Indepenent of DB
    1. 비즈니스 로직이 DB에 바인딩 되지 않음
5. Indepenent of any external agency
    1. 비즈니스 로직은 outside world에 대해 전혀 알지 못함

마틴 👨🏻: 어차피 같은 소리 하니까 다양한 아키텍처를 단일 아이디어로 통합하자 → Clean Architecture 

![클린 아키텍처 다이어그램](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/af2a7b75-c708-489d-93df-72510ade6213/Untitled.png)

클린 아키텍처 다이어그램

저 다이어그램은 소프트웨어의 각각의 다른 영역을 나타낸다.

outer circles

- mechanisms

inner circles

- 정책

이 아키텍처를 작동시키는 가장 우선적인 규칙은 Dependency Rule이다.

### The Dependency Rule

- 소스 코드의 종속성은 안쪽으로만 향할 수 있음
- inner circles 안에 있는 것들은 outer circles에 대해 아무것도 알 수 없음
- 특히, outer circles에 선언된 이름은 inner circles에서 언급되면 안된다. (함수, 클래스 등)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/b7cc7c63-f1fa-419f-a32b-20ec0aeaaa97/Untitled.png)

**즉, outer circles이 inner circles에 영향을 미쳐선 안된다!**

---

[https://github.com/kudoleh/iOS-Clean-Architecture-MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)

프로젝트를 예시로 clean architecture을 학습해본다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/69836f00-ce5f-4a28-9f23-19cc516554ec/Untitled.png)

### Entity

엔티티는 간단히

- 데이터 구조 및 함수 집합
- Enterprise wide business rules를 캡슐화한 것. 즉, 가장 높은 수준의 규칙을 캡슐화 한 것

저 프로젝트에서는 Movie, Movie Query이다.

```swift
//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//
import Foundation

struct Movie: Equatable, Identifiable {
    typealias Identifier = String
    enum Genre {
        case adventure
        case scienceFiction
    }
    let id: Identifier
    let title: String?
    let genre: Genre?
    let posterPath: String?
    let overview: String?
    let releaseDate: Date?
}

struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}
```

### Use Cases

use cases는

- 시스템의 동작을 사용자의 입장에서 표현한 시나리오
- 시스템의 모든 Use case를 캡슐화하고 구현한다.
- 엔티티와의 데이터 흐름을 조정하고, 해당 엔티티가 use case의 목표를 달성하도록 지시 하는 역할을 한다.

→ 사용자 Input에 대한 시나리오 인 듯

저 프로젝트에서는 SearchMoviesUseCase가 있다.

```swift
//
//  SearchMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22.02.19.
//

import Foundation

protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let moviesRepository: MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(moviesRepository: MoviesRepository,
         moviesQueriesRepository: MoviesQueriesRepository) {

        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
    }

    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        return moviesRepository.fetchMoviesList(query: requestValue.query,
                                                page: requestValue.page,
                                                cached: cached,
                                                completion: { result in

            if case .success = result {
                self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
            }

            completion(result)
        })
    }
}

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
```

사용자가 영화를 검색하는 Use Case

excute에서 실제 API 콜하는 코드가 들어간다.

코드를 보니

Use cases는 사용자에게 보여줄 출력을 위해 해당 출력을 생성하기 위한 처리 단계를 기술하는 곳이라고 볼 수 있다.

그래서 Use case를 Use case Interactor라고도 한다.

Dependency룰에 의해 보면,

Entity는 Use case에 대해 알지 못하고, Use case는 Entity에 대해 알고 있다.

하지만 Use Case의 계층 변경이 Entity에 영향을 끼쳐서는 안되고, Use case는 DB, UI같은 외부 환경의 변경(ex. 외부 프레임 워크 등) 으로 영향 받지 않아야 한다.

### Interface Adapters ([View]Controllers, Gateways, Presenters)

(View) Controlles, Gateways, Presenters가 속한 영역.

Interface Adapter라고도 하고, Presentation Layer라고도 한다.

이 계층은 데이터가 들어오면

Entity, User case에 가장 편리한 format에서 DB 등과 같은 외부 프레임워크에 가장 편리한 Format으로 변환되는 곳.

(ex. 데이터가 실제로 들어와서 Cell에 세팅되는 느낌)

예시 프로젝트로 보면…

각 화면의 View, ViewModel 들이 들어있다. 

실제로 MVVM 패턴으로 구현되어야할 부분이 이 부분인 듯 하다.

 

### Frameworks & Drivers

이 계층에는 일반적으로 DB, 프레임워크 같은 것들로 구성된다.

---

꼭 이 계층을 유지해야 하나?

아니다. 원이 몇 개 든 저 Dependency Rule만 안쪽으로 향하면 된다.

안쪽으로 향할수록 추상화 수준이 증가하면 된다.

### Crossing boundaries

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/359393ae-cb52-491c-a6ff-1df3cb53b030/Untitled.png)

다이어그램을 보면,

Controller에서 시작해서 Use Case Interactor을 거쳐 Presenter에서 실행된다.

오잉! Use Case는 Presenter보다 안에 있어서 호출하면 안되는데?

그래서 다이어그램을 보면..

Output Port라는 “인터페이스”를 둔다.

그래서 Use Case는 이 Output port에 있는 인터페이스를 호출한다.

그리고 Presenter는 이 Output port 인터페이스를 구현한다.

직접 Presenter의 구현체에 접근하지 않고 Output port 인터페이스를 통해 접근한다는 것이 가장 중요하다.

다시 정리해보자면…

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/36b12e94-5525-40d1-848a-0d6235050a7e/Untitled.png)

앞으로 Swift의 Clean Architecture을 볼 때

Domain Layer → UseCase + Entities → 데이터를 받아와서 가공하는, 비즈니스 로직 처리

Data Layer → API, DB(Data Repository) + Entities → 어쨋든 데이터를 받아오는 주체 + 원본 데이터

Presentation Layer → MVVM으로 구현하는 View, ViewModel
