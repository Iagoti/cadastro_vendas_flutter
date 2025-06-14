import 'package:cadastro_vendas_flutter/models/cliente_model.dart';
import 'package:cadastro_vendas_flutter/models/produto_model.dart';
import 'package:cadastro_vendas_flutter/views/cliente_form_view.dart';
import 'package:cadastro_vendas_flutter/views/cliente_list_view.dart';
import 'package:cadastro_vendas_flutter/views/dashboard_view.dart';
import 'package:cadastro_vendas_flutter/views/login_view.dart';
import 'package:cadastro_vendas_flutter/views/produto_form_view.dart';
import 'package:cadastro_vendas_flutter/views/produto_list_view.dart';
import 'package:cadastro_vendas_flutter/views/sql_query_view.dart';
import 'package:cadastro_vendas_flutter/views/venda_create_view.dart';
import 'package:cadastro_vendas_flutter/views/venda_list_view.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginView(),
    '/dashboard': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DashboardView(username: args['username']);
    },
    '/vendas': (context) => const VendaListView(),
    '/cadastrar-venda': (context) => const VendaCreateView(),
    '/lista-clientes': (context) => const ClienteListView(),
    '/cliente-form': (context) {
      final cliente = ModalRoute.of(context)?.settings.arguments as ClienteModel?;
      return ClienteFormView(cliente: cliente);
    },
    '/lista-produtos': (context) => const ProdutoListView(),
    '/produto-form': (context) {
      final produto = ModalRoute.of(context)?.settings.arguments as ProdutoModel?;
      return ProdutoFormView(produto: produto);
    },
    '/sql-query': (context) => const SqlQueryView(),
  };
}