<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RestaurantController;
use App\Http\Controllers\OrderItemController;
use App\Http\Controllers\ProfilController;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    Route::get('/user', [UserController::class, 'index']);
    Route::post('/getDataUser', [UserController::class, 'getDataUser']);
    Route::put('/update', [UserController::class, 'update']);
    Route::post('/logout', [UserController::class, 'logout']);

    Route::get('/profil', [ProfilController::class, 'index']);
    Route::put('/profil/update', [ProfilController::class, 'update']);
    Route::post('/profil', [ProfilController::class, 'show']);

    Route::get('/restaurant', [RestaurantController::class, 'index']);
    Route::post('/restaurant', [RestaurantController::class, 'store']);
    Route::post('/restaurant/show', [RestaurantController::class, 'show']);
    Route::put('/restaurant/update', [RestaurantController::class, 'update']);
    Route::delete('/restaurant/delete', [RestaurantController::class, 'destroy']);

    Route::get('/menu', [MenuController::class, 'index']);
    Route::post('/menu', [MenuController::class, 'store']);
    Route::post('/menu/show', [MenuController::class, 'show']);
    Route::put('/menu/update', [MenuController::class, 'update']);
    Route::delete('/menu/delete', [MenuController::class, 'destroy']);

    Route::get('/order', [OrderController::class, 'index']);
    Route::post('/order', [OrderController::class, 'store']);
    Route::post('/order/show', [OrderController::class, 'show']);
    Route::put('/order/update', [OrderController::class, 'update']);
    Route::delete('/order/delete', [OrderController::class, 'destroy']);

    Route::get('/orderItem', [OrderItemController::class, 'index']);
    Route::post('/orderItem', [OrderItemController::class, 'store']);
    Route::post('/orderItem/show', [OrderItemController::class, 'show']);
    Route::put('/orderItem/update', [OrderItemController::class, 'update']);
    Route::delete('/orderItem/delete', [OrderItemController::class, 'destroy']);


    
});

