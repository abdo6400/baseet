import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductToCartEvent>(_onAddToCart);
    on<RemoveProductFromCartEvent>(_onRemoveFromCart);
    on<UpdateItemQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  void _onAddToCart(AddProductToCartEvent event, Emitter<CartState> emit) {
    final currentItems = List<CartItemEntity>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == event.product.id);

    if (existingIndex != -1) {
      final existing = currentItems[existingIndex];
      final newQuantity = existing.quantity + event.quantity;
      currentItems[existingIndex] = existing.copyWith(quantity: newQuantity);
    } else {
      currentItems.add(CartItemEntity(product: event.product, quantity: event.quantity));
    }

    emit(state.copyWith(items: currentItems));
  }

  void _onRemoveFromCart(RemoveProductFromCartEvent event, Emitter<CartState> emit) {
    final currentItems = state.items.where((item) => item.product.id != event.productId).toList();
    emit(state.copyWith(items: currentItems));
  }

  void _onUpdateQuantity(UpdateItemQuantityEvent event, Emitter<CartState> emit) {
    if (event.newQuantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final currentItems = List<CartItemEntity>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == event.productId);
    if (index != -1) {
      currentItems[index] = currentItems[index].copyWith(quantity: event.newQuantity);
      emit(state.copyWith(items: currentItems));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}
