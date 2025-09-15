// Centralização de exports para o sistema de Injeção de Dependências
// Este arquivo centraliza todos os exports relacionados ao DI,
// facilitando a importação em outros arquivos do projeto.

// Core DI
export 'locator.dart';

// Models - Expedition Cart Route Internship
export '../domain/models/expedition_cart_route_internship_group_consultation_model.dart';
export '../domain/models/expedition_cart_route_internship_group_model.dart';
export '../domain/models/expedition_cart_route_internship_consultation_model.dart';

// Models - Expedition Enums
export '../domain/models/expedition_origem_model.dart';
export '../domain/models/expedition_item_situation_model.dart';
export '../domain/models/expedition_situation_model.dart'
    hide ExpedicaoSituacaoModel;
export '../domain/models/expedition_cart_situation_model.dart';

// Models - Other
export '../domain/models/separate_model.dart';
export '../domain/models/separate_consultation_model.dart';
export '../domain/models/separate_item_model.dart';
export '../domain/models/separate_item_consultation_model.dart';
export '../domain/models/stock_product_consultation_model.dart';
export '../domain/models/situation_model.dart';

// Repositories - Interfaces
export '../domain/repositories/basic_repository.dart';
export '../domain/repositories/basic_consultation_repository.dart';
export '../domain/repositories/user_repository.dart';
export '../domain/repositories/user_system_repository.dart';

// Repositories - Implementations
export '../data/repositories/user_repository_impl.dart';
export '../data/repositories/user_system_repository_impl.dart';
export '../data/repositories/separate_repository_impl.dart';
export '../data/repositories/separate_consultation_repository_impl.dart';
export '../data/repositories/separate_item_repository_impl.dart';
export '../data/repositories/separate_item_consultation_repository_impl.dart';
export '../data/repositories/stock_product_consultation_repository_impl.dart';
export '../data/repositories/expedition_cart_route_internship_gorup_consultation_repository_impl.dart';
export '../data/repositories/expedition_cart_route_internship_gorup__impl.dart';
export '../data/repositories/expedition_cart_route_internship_consultation_repository_impl.dart'
    hide ExpeditionCartRouteInternshipConsultationRepositoryImpl;

// Services
export '../data/datasources/config_service.dart';
export '../data/datasources/user_preferences_service.dart';
export '../data/services/socket_service.dart';

// Use Cases
export '../domain/usecases/register_user_usecase.dart';
export '../domain/usecases/login_user_usecase.dart';

// ViewModels
export '../domain/viewmodels/register_viewmodel.dart';
export '../domain/viewmodels/auth_viewmodel.dart';
export '../domain/viewmodels/config_viewmodel.dart';
export '../domain/viewmodels/user_selection_viewmodel.dart';
export '../domain/viewmodels/profile_viewmodel.dart';
export '../domain/viewmodels/socket_viewmodel.dart';
