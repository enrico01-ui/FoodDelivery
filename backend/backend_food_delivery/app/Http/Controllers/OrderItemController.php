<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItem;

class OrderItemController extends Controller
{
    // protected $fillable = [
    //     'order_id',
    //     'item_id',
    //     'quantity',
    //     'price',

    // ];

    // public function menu()
    // {
    //     return $this->belongsTo(Menu::class, 'item_id', 'item_id'); 
    // }

    // public function order()
    // {
    //     return $this->belongsTo(Order::class, 'order_id', 'order_id'); 
    // }

    public function index()
    {
        $orderItems = OrderItem::all();
        return response()->json($orderItems);
    }

    public function store(Request $request)
    {
        $request->validate(
            [
                'order_id' => 'required|string|exists:orders,id',
                'item_id' => 'required|string|exists:menus,item_id',
                'quantity' => 'required|integer',
                'price' => 'required|numeric',
            ]
        );

        $orderItem = OrderItem::create([
            'order_id' => $request->order_id,
            'item_id' => $request->item_id,
            'quantity' => $request->quantity,
            'price' => $request->price,
        ]);

        return response()->json([
            'message' => 'Order Item Created Successfully',
            'data' => $orderItem
        ]);
    }

    public function show(Request $request)
    {
        $request->validate(
            [
                'order_id' => 'required|string|exists:orders,id',
                'item_id' => 'required|string|exists:menus,item_id',
            ]
        );

        $orderItem = OrderItem::with(['menu', 'order'])
                        ->where('order_id', 'like', '%' . $request->order_id . '%')
                        ->where('item_id', 'like', '%' . $request->item_id . '%')
                        ->first();
        
        if($orderItem){
            return response()->json([
                'message' => 'Order Item Found',
                'data' => $orderItem
            ]);
        }else{
            return response()->json([
                'message' => 'Order Item Not Found',
            ], 404);
        }
    }
    

    public function update(Request $request)
    {
        $request->validate(
            [
                'order_id' => 'required|string|exists:orders,id',
                'item_id' => 'required|string|exists:menus,item_id',
                'quantity' => 'required|integer',
                'price' => 'required|numeric',
            ]
        );

        $orderItem = OrderItem::where('order_id', 'like', '%' . $request->order_id . '%')
                        ->where('item_id', 'like', '%' . $request->item_id . '%')
                        ->first();
        
        if($orderItem){
            $orderItem->update([
                'quantity' => $request->quantity,
                'price' => $request->price,
            ]);

            return response()->json([
                'message' => 'Order Item Updated Successfully',
                'data' => $orderItem
            ]);
        }else{
            return response()->json([
                'message' => 'Order Item Not Found',
            ], 404);
        }
    }

    public function destroy(Request $request)
    {
        $request->validate(
            [
                'order_id' => 'required|string|exists:orders,id',
                'item_id' => 'required|string|exists:menus,item_id',
            ]
        );

        $orderItem = OrderItem::where('order_id', 'like', '%' . $request->order_id . '%')
                        ->where('item_id', 'like', '%' . $request->item_id . '%')
                        ->first();

        if($orderItem){
            $orderItem->delete();
            return response()->json([
                'message' => 'Order Item Deleted Successfully',
            ]);
        }else{
            return response()->json([
                'message' => 'Order Item Not Found',
            ], 404);
        }
    }

}
